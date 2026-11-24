defmodule EnrouteHaye.Trips.ItineraryGenerator do
  @moduledoc "Builds an itinerary from a persisted trip without changing user order."

  alias EnrouteHaye.Trips.{BudgetCalculator, RouteEstimator}

  def generate(trip) do
    stops = Enum.sort_by(trip.trip_stops || [], & &1.order_index)
    {assigned, warnings} = assign_default_days(stops)
    day_groups = Enum.group_by(assigned, & &1.generated_day)
    days = day_count(trip, assigned)
    budget = BudgetCalculator.calculate(trip)

    schedule =
      if days > 0 do
        Enum.map(1..days, fn day_number ->
          day_stops = Map.get(day_groups, day_number, [])
          date = if trip.start_date, do: Date.add(trip.start_date, day_number - 1), else: nil

          %{
            number: day_number,
            date: date,
            destinations: route_stops(day_stops),
            accommodation: accommodation_for_day(trip, day_number),
            food: if(day_number == 1, do: Enum.map(trip.food_selections || [], & &1.food), else: []),
            event: event_for_day(trip.selected_event, date, day_number),
            estimated_daily_budget: daily_budget(budget, days)
          }
        end)
      else
        []
      end

    warnings = warnings ++ date_warnings(trip) ++ budget.missing

    %{
      trip: trip,
      overview: %{
        title: trip.title,
        starting_province: trip.starting_province,
        starting_district: trip.starting_district,
        destination_province: trip.destination_province,
        destination_district: trip.destination_district,
        start_date: trip.start_date,
        end_date: trip.end_date,
        duration_days: days,
        traveller_count: trip.traveller_count,
        currency: trip.currency || "ZMW"
      },
      transport: trip.transport_segments || [],
      event: trip.selected_event,
      days: schedule,
      destinations: Enum.map(assigned, & &1.site),
      food: Enum.map(trip.food_selections || [], & &1.food),
      music: Enum.map(trip.audio_selections || [], & &1.audio),
      accommodation: trip.accommodation_selections || [],
      budget: budget,
      warnings: Enum.uniq(warnings)
    }
  end

  defp assign_default_days(stops) do
    Enum.map_reduce(stops, {1, []}, fn stop, {next_day, warnings} ->
      if stop.day_number do
        warning = if stop.day_number < next_day, do: ["Destination day assignment conflicts with the selected sequence." | warnings], else: warnings
        {Map.put(stop, :generated_day, stop.day_number), {max(next_day, stop.day_number + 1), warning}}
      else
        {Map.put(stop, :generated_day, next_day), {next_day + 1, warnings}}
      end
    end)
    |> then(fn {assigned, {_next_day, warnings}} -> {assigned, Enum.reverse(warnings)} end)
  end

  defp route_stops(stops) do
    Enum.with_index(stops)
    |> Enum.map(fn {stop, index} ->
      previous = if index == 0, do: nil, else: Enum.at(stops, index - 1)
      route = if previous, do: RouteEstimator.between(previous.site, stop.site), else: nil

      %{
        stop: stop,
        site: stop.site,
        order_index: stop.order_index,
        notes: stop.notes,
        route_from_previous: route
      }
    end)
  end

  defp day_count(trip, stops) do
    date_days = BudgetCalculator.trip_days(trip)
    assigned_days = Enum.map(stops, &(&1.generated_day || 0))
    max(date_days, Enum.max(assigned_days, fn -> 0 end))
  end

  defp accommodation_for_day(trip, day_number) do
    Enum.find(trip.accommodation_selections || [], fn selection ->
      check_in = selection.check_in || trip.start_date
      check_out = selection.check_out || trip.end_date

      check_in && check_out && trip.start_date &&
        Date.compare(Date.add(trip.start_date, day_number - 1), check_in) != :lt &&
        Date.compare(Date.add(trip.start_date, day_number - 1), check_out) == :lt
    end)
  end

  defp event_for_day(nil, _date, _day), do: nil
  defp event_for_day(event, nil, 1), do: event
  defp event_for_day(event, date, _day) do
    event_date = event.start_date && NaiveDateTime.to_date(event.start_date)
    if event_date == date, do: event, else: nil
  end

  defp daily_budget(%{known_total: total}, days) when days > 0, do: Decimal.div(total, Decimal.new(days))
  defp daily_budget(_budget, _days), do: nil

  defp date_warnings(%{start_date: nil}), do: ["Add travel dates to assign calendar dates to itinerary days."]
  defp date_warnings(%{end_date: nil}), do: ["Add an end date to complete the trip duration."]
  defp date_warnings(_), do: []
end
