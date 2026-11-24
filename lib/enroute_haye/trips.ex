defmodule EnrouteHaye.Trips do
  @moduledoc "Persistence and access control for saved trip plans."

  import Ecto.Query

  alias EnrouteHaye.Accounts.Scope
  alias EnrouteHaye.Repo
  alias EnrouteHaye.Schema.{Accommodation, Food}

  alias EnrouteHaye.Trips.{
    Trip,
    TripAccommodation,
    TripAudio,
    TripFood,
    TripStop,
    TripTransportSegment
  }

  @trip_preloads [
    :user,
    :selected_event,
    [trip_stops: :site],
    [transport_segments: [:road, :airline]],
    [food_selections: :food],
    [audio_selections: :audio],
    [accommodation_selections: :accommodation],
    :expenses
  ]

  def create_draft(scope, guest_token, attrs \\ %{}) do
    attrs = Map.put_new(attrs, :title, "Zambia trip plan")
    user_id = user_id(scope)

    %Trip{}
    |> Trip.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user_id)
    |> Ecto.Changeset.put_change(
      :guest_token_hash,
      if(user_id, do: nil, else: token_hash(guest_token))
    )
    |> Repo.insert()
  end

  def ensure_draft(scope, guest_token, attrs \\ %{}) do
    user_id = user_id(scope)
    guest_hash = token_hash(guest_token)

    cond do
      user_id && guest_hash ->
        case Repo.get_by(Trip, guest_token_hash: guest_hash, user_id: nil) do
          %Trip{} = trip ->
            trip
            |> Ecto.Changeset.change(user_id: user_id, guest_token_hash: nil)
            |> Repo.update()

          nil ->
            find_or_create_user_draft(user_id, attrs)
        end

      user_id ->
        find_or_create_user_draft(user_id, attrs)

      guest_hash ->
        case Repo.get_by(Trip, guest_token_hash: guest_hash, user_id: nil) do
          %Trip{} = trip -> {:ok, trip}
          nil -> create_draft(nil, guest_token, attrs)
        end

      true ->
        {:error, :guest_access_required}
    end
  end

  def get_trip(scope, trip_id, guest_token \\ nil) do
    with {:ok, id} <- parse_id(trip_id),
         query <- owned_trip_query(scope, id, guest_token),
         %Trip{} = trip <- Repo.one(query) do
      trip = Repo.preload(trip, @trip_preloads)

      %{
        trip
        | trip_stops: Enum.sort_by(trip.trip_stops, & &1.order_index),
          transport_segments: Enum.sort_by(trip.transport_segments, & &1.order_index)
      }
    else
      _ -> nil
    end
  end

  def get_trip!(scope, trip_id, guest_token \\ nil) do
    case get_trip(scope, trip_id, guest_token) do
      nil -> raise Ecto.NoResultsError, queryable: Trip
      trip -> trip
    end
  end

  def list_trips(scope, filters \\ %{})

  def list_trips(%Scope{user: %{}}, filters) do
    status = filters[:status] || filters["status"]
    search = filters[:search] || filters["search"] || ""

    Trip
    |> maybe_status(status)
    |> maybe_search(search)
    |> order_by([t], desc: t.updated_at)
    |> preload([:user, :selected_event, :trip_stops])
    |> Repo.all()
  end

  def list_trips(_scope, _filters), do: []

  def update_trip(scope, trip_id, guest_token, attrs) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      trip
      |> Trip.changeset(attrs)
      |> Repo.update()
    else
      nil -> {:error, :not_found}
    end
  end

  def update_budget(scope, trip_id, guest_token, amount) do
    update_trip(scope, trip_id, guest_token, %{budget_estimate: amount})
  end

  def delete_trip(scope, trip_id, guest_token) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      Repo.delete(trip)
    else
      nil -> {:error, :not_found}
    end
  end

  def add_destination(scope, trip_id, guest_token, site_id, day_number \\ nil, notes \\ nil) do
    with {:ok, id} <- parse_id(site_id),
         %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         false <- Enum.any?(trip.trip_stops, &(&1.site_id == id)) do
      order_index = length(trip.trip_stops)

      %TripStop{}
      |> TripStop.changeset(%{
        trip_id: trip.id,
        site_id: id,
        day_number: day_number,
        order_index: order_index,
        notes: notes
      })
      |> Repo.insert()
    else
      true -> {:error, :already_selected}
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def remove_destination(scope, trip_id, guest_token, site_id) do
    with {:ok, id} <- parse_id(site_id),
         %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      Repo.transaction(fn ->
        Repo.delete_all(from(s in TripStop, where: s.trip_id == ^trip.id and s.site_id == ^id))

        trip.id
        |> stops_query()
        |> Repo.all()
        |> Enum.with_index()
        |> Enum.each(fn {stop, index} ->
          stop |> Ecto.Changeset.change(order_index: index) |> Repo.update!()
        end)

        :ok
      end)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def reorder_destinations(scope, trip_id, guest_token, ordered_site_ids)
      when is_list(ordered_site_ids) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         {:ok, ids} <- normalize_ids(ordered_site_ids),
         true <- MapSet.new(ids) == MapSet.new(Enum.map(trip.trip_stops, & &1.site_id)) do
      stops = Map.new(trip.trip_stops, &{&1.site_id, &1})

      Repo.transaction(fn ->
        Enum.with_index(ids)
        |> Enum.each(fn {site_id, index} ->
          stops
          |> Map.fetch!(site_id)
          |> Ecto.Changeset.change(order_index: index)
          |> Repo.update!()
        end)

        :ok
      end)
    else
      nil -> {:error, :not_found}
      false -> {:error, :destination_set_mismatch}
      error -> error
    end
  end

  def reorder_destinations(_scope, _trip_id, _guest_token, _ids),
    do: {:error, :invalid_destinations}

  def assign_destination_day(scope, trip_id, guest_token, site_id, day_number) do
    with {:ok, id} <- parse_id(site_id),
         true <- is_integer(day_number) and day_number > 0,
         %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         %TripStop{} = stop <- Repo.get_by(TripStop, trip_id: trip.id, site_id: id) do
      stop |> TripStop.changeset(%{day_number: day_number}) |> Repo.update()
    else
      false -> {:error, :invalid_day}
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def update_destination_notes(scope, trip_id, guest_token, site_id, notes) do
    with {:ok, id} <- parse_id(site_id),
         %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         %TripStop{} = stop <- Repo.get_by(TripStop, trip_id: trip.id, site_id: id) do
      stop |> TripStop.changeset(%{notes: notes}) |> Repo.update()
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def save_transport_segments(scope, trip_id, guest_token, segments) when is_list(segments) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      Repo.transaction(fn ->
        Repo.delete_all(from(s in TripTransportSegment, where: s.trip_id == ^trip.id))

        segments
        |> Enum.with_index()
        |> Enum.each(fn {attrs, index} ->
          attrs = Map.merge(attrs, %{trip_id: trip.id, order_index: index})

          %TripTransportSegment{}
          |> TripTransportSegment.changeset(attrs)
          |> Repo.insert!()
        end)

        :ok
      end)
    else
      nil -> {:error, :not_found}
    end
  end

  def save_food_selections(scope, trip_id, guest_token, selections) when is_list(selections) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         {:ok, ids} <- normalize_ids(Enum.map(selections, &selection_id/1)) do
      prices =
        Repo.all(from(f in Food, where: f.id in ^ids, select: {f.id, f.price})) |> Map.new()

      existing =
        Repo.all(from(f in TripFood, where: f.trip_id == ^trip.id)) |> Map.new(&{&1.food_id, &1})

      Repo.transaction(fn ->
        Enum.each(existing, fn {id, selection} ->
          if id not in ids, do: Repo.delete!(selection)
        end)

        Enum.each(selections, fn selection ->
          id = selection_id(selection)
          quantity = selection_quantity(selection)
          price = Map.get(prices, id)
          row = Map.get(existing, id) || %TripFood{}

          row
          |> TripFood.changeset(%{
            trip_id: trip.id,
            food_id: id,
            quantity: quantity,
            unit_price_estimate: price
          })
          |> Repo.insert_or_update!()
        end)

        :ok
      end)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def save_audio_selections(scope, trip_id, guest_token, audio_ids) when is_list(audio_ids) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         {:ok, ids} <- normalize_ids(audio_ids) do
      existing =
        Repo.all(from(a in TripAudio, where: a.trip_id == ^trip.id))
        |> Map.new(&{&1.audio_id, &1})

      Repo.transaction(fn ->
        Enum.each(existing, fn {id, selection} ->
          if id not in ids, do: Repo.delete!(selection)
        end)

        Enum.each(ids, fn id ->
          unless Map.has_key?(existing, id) do
            %TripAudio{}
            |> TripAudio.changeset(%{trip_id: trip.id, audio_id: id})
            |> Repo.insert!()
          end
        end)

        :ok
      end)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def select_accommodation(scope, trip_id, guest_token, accommodation_id, attrs \\ %{}) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         {:ok, id} <- parse_id(accommodation_id),
         %Accommodation{} = accommodation <- Repo.get(Accommodation, id) do
      Repo.get_by(TripAccommodation, trip_id: trip.id)
      |> case do
        nil -> %TripAccommodation{}
        selection -> selection
      end
      |> TripAccommodation.changeset(
        Map.merge(attrs, %{
          trip_id: trip.id,
          accommodation_id: id,
          nightly_price_estimate: accommodation.price_per_night
        })
      )
      |> Repo.insert_or_update()
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def clear_accommodation(scope, trip_id, guest_token) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      Repo.delete_all(from(a in TripAccommodation, where: a.trip_id == ^trip.id))
      :ok
    else
      nil -> {:error, :not_found}
    end
  end

  def add_expense(scope, trip_id, guest_token, attrs) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token) do
      %EnrouteHaye.Trips.TripExpense{}
      |> EnrouteHaye.Trips.TripExpense.changeset(Map.put(attrs, :trip_id, trip.id))
      |> Repo.insert()
    else
      nil -> {:error, :not_found}
    end
  end

  def delete_expense(scope, trip_id, guest_token, expense_id) do
    with %Trip{} = trip <- get_trip(scope, trip_id, guest_token),
         {:ok, id} <- parse_id(expense_id),
         %EnrouteHaye.Trips.TripExpense{} = expense <-
           Repo.get_by(EnrouteHaye.Trips.TripExpense, id: id, trip_id: trip.id) do
      Repo.delete(expense)
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def guest_token_hash(token) when is_binary(token), do: token_hash(token)
  def guest_token_hash(_), do: nil

  defp find_or_create_user_draft(user_id, attrs) do
    case Repo.one(
           from(t in Trip,
             where: t.user_id == ^user_id and t.status == "draft",
             order_by: [desc: t.updated_at],
             limit: 1
           )
         ) do
      %Trip{} = trip -> {:ok, trip}
      nil -> create_draft(%Scope{user: %EnrouteHaye.Accounts.User{id: user_id}}, nil, attrs)
    end
  end

  defp owned_trip_query(scope, id, guest_token) do
    user_id = user_id(scope)

    case user_id do
      nil ->
        hash = token_hash(guest_token)
        from(t in Trip, where: t.id == ^id and is_nil(t.user_id) and t.guest_token_hash == ^hash)

      user_id ->
        from(t in Trip, where: t.id == ^id and t.user_id == ^user_id)
    end
  end

  defp user_id(%Scope{user: %{id: id}}), do: id
  defp user_id(_), do: nil

  defp token_hash(token) when is_binary(token) and byte_size(token) >= 32,
    do: :crypto.hash(:sha256, token)

  defp token_hash(_), do: nil

  defp parse_id(id) when is_integer(id) and id > 0, do: {:ok, id}

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {value, ""} when value > 0 -> {:ok, value}
      _ -> {:error, :invalid_id}
    end
  end

  defp parse_id(_), do: {:error, :invalid_id}

  defp normalize_ids(ids) do
    parsed = Enum.map(ids, &parse_id/1)

    if Enum.all?(parsed, &match?({:ok, _}, &1)) do
      values = Enum.map(parsed, fn {:ok, id} -> id end)

      if length(values) == length(Enum.uniq(values)),
        do: {:ok, values},
        else: {:error, :duplicate_destination}
    else
      {:error, :invalid_id}
    end
  end

  defp selection_id(%{id: id}), do: id
  defp selection_id(%{"id" => id}), do: id
  defp selection_id(id), do: id

  defp selection_quantity(%{quantity: quantity}) when is_integer(quantity), do: quantity
  defp selection_quantity(%{"quantity" => quantity}) when is_integer(quantity), do: quantity
  defp selection_quantity(_), do: 1

  defp stops_query(trip_id),
    do: from(s in TripStop, where: s.trip_id == ^trip_id, order_by: [asc: s.order_index])

  defp maybe_status(query, nil), do: query
  defp maybe_status(query, status), do: where(query, [t], t.status == ^status)

  defp maybe_search(query, ""), do: query

  defp maybe_search(query, search) do
    term = "%#{search}%"
    where(query, [t], ilike(t.title, ^term) or ilike(t.description, ^term))
  end
end
