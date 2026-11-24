defmodule EnrouteHaye.Trips.BudgetCalculator do
  @moduledoc "Calculates known trip costs and reports missing price data."

  alias Decimal, as: D

  def calculate(trip) do
    travellers = max(trip.traveller_count || 1, 1)
    days = trip_days(trip)

    transport = transport_cost(trip)
    accommodation = accommodation_cost(trip)
    food = food_cost(trip, travellers)
    entrances = entrance_cost(trip, travellers)
    activities = activity_cost(trip)
    other = other_cost(trip)

    categories = %{
      transport: transport,
      accommodation: accommodation,
      food: food,
      entrance_fees: entrances,
      activities: activities,
      other: other
    }

    known_total = categories |> Map.values() |> Enum.reduce(zero(), &D.add(&2, &1.amount))
    missing = categories |> Map.values() |> Enum.flat_map(& &1.missing)
    per_traveller = D.div(known_total, D.new(travellers))
    per_day = if days > 0, do: D.div(known_total, D.new(days)), else: nil

    %{
      currency: trip.currency || "ZMW",
      categories: categories,
      known_total: known_total,
      total_complete?: missing == [],
      missing: Enum.uniq(missing),
      per_traveller: per_traveller,
      per_day: per_day,
      traveller_count: travellers,
      day_count: days
    }
  end

  def trip_days(%{start_date: %Date{} = start_date, end_date: %Date{} = end_date}) do
    max(Date.diff(end_date, start_date) + 1, 0)
  end

  def trip_days(%{duration_days: days}) when is_integer(days), do: days
  def trip_days(_), do: 0

  defp transport_cost(%{transport_segments: []}), do: category(zero(), ["Transport has not been selected."])
  defp transport_cost(trip) do
    Enum.reduce(trip.transport_segments, category(zero(), []), fn segment, acc ->
      provider_price = (segment.road && segment.road.price) || (segment.airline && segment.airline.price)
      value = segment.estimated_cost || provider_price

      if value do
        add_cost(acc, multiply(value, trip.traveller_count || 1))
      else
        add_missing(acc, "No price is recorded for #{segment.mode} transport.")
      end
    end)
  end

  defp accommodation_cost(%{accommodation_selections: []}), do: category(zero(), ["Accommodation has not been selected."])
  defp accommodation_cost(trip) do
    Enum.reduce(trip.accommodation_selections, category(zero(), []), fn selection, acc ->
      price = selection.nightly_price_estimate || (selection.accommodation && selection.accommodation.price_per_night)
      check_in = selection.check_in || trip.start_date
      check_out = selection.check_out || trip.end_date

      cond do
        is_nil(price) -> add_missing(acc, "No nightly accommodation price is available.")
        not match?(%Date{}, check_in) or not match?(%Date{}, check_out) ->
          add_missing(acc, "Accommodation cost needs check-in and check-out dates.")

        Date.diff(check_out, check_in) <= 0 -> add_missing(acc, "Accommodation stay dates are incomplete.")
        true -> add_cost(acc, multiply(price, Date.diff(check_out, check_in)))
      end
    end)
  end

  defp food_cost(%{food_selections: selections}, travellers) do
    Enum.reduce(selections, category(zero(), []), fn selection, acc ->
      price = selection.unit_price_estimate || get_in(selection, [:food, Access.key(:price)])

      if price do
        add_cost(acc, multiply(price, (selection.quantity || 1) * travellers))
      else
        name = (selection.food && selection.food.name) || "selected food"
        add_missing(acc, "No price is recorded for #{name}.")
      end
    end)
  end

  defp entrance_cost(%{trip_stops: stops}, travellers) do
    Enum.reduce(stops, category(zero(), []), fn stop, acc ->
      site = stop.site

      if is_integer(site.price) do
        add_cost(acc, multiply(site.price, travellers))
      else
        add_missing(acc, "No entrance fee is available for #{site.name}.")
      end
    end)
  end

  defp activity_cost(%{selected_event: nil}), do: category(zero(), [])
  defp activity_cost(%{selected_event: event}) do
    category(zero(), ["No price is recorded for event #{event.title}."])
  end

  defp other_cost(%{expenses: expenses}) do
    Enum.reduce(expenses, category(zero(), []), fn expense, acc ->
      if expense.currency == "ZMW" do
        add_cost(acc, expense.amount)
      else
        add_missing(acc, "#{expense.title} is in #{expense.currency}; it was excluded from the ZMW total.")
      end
    end)
  end

  defp category(amount, missing), do: %{amount: amount, missing: missing, estimate?: true}
  defp add_cost(category, amount), do: %{category | amount: D.add(category.amount, decimal(amount))}
  defp add_missing(category, item), do: %{category | missing: [item | category.missing]}

  defp multiply(amount, count), do: D.mult(decimal(amount), D.new(count))
  defp decimal(%D{} = value), do: value
  defp decimal(value) when is_integer(value), do: D.new(value)
  defp decimal(value) when is_float(value), do: D.from_float(value)
  defp decimal(value) when is_binary(value), do: D.new(value)
  defp zero, do: D.new(0)
end
