defmodule EnrouteHayeWeb.Unauth.Journey do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.{CxtAccommodation, CxtAudio, CxtEvent, CxtFood, CxtRoad, CxtSite}
  alias EnrouteHaye.Trips
  alias EnrouteHaye.Trips.{BudgetCalculator, ItineraryGenerator, RouteEstimator, Trip}

  @steps ~w(Basics Transport Ceremony Destinations Food\ &\ Music Accommodation Review)a

  @impl true
  def mount(params, session, socket) do
    guest_token = session["trip_guest_access"] || session[:trip_guest_access]
    scope = socket.assigns.current_scope

    result =
      case params["trip_id"] do
        nil ->
          Trips.ensure_draft(scope, guest_token)

        trip_id ->
          case Trips.get_trip(scope, trip_id, guest_token) do
            nil -> {:error, :not_found}
            trip -> {:ok, trip}
          end
      end

    case result do
      {:ok, trip} ->
        trip = Trips.get_trip(scope, trip.id, guest_token)
        socket = load_planner(socket, trip, guest_token)
        {:ok, socket}

      {:error, _reason} ->
        {:ok,
         socket
         |> put_flash(
           :error,
           "That saved trip could not be found or you do not have access to it."
         )
         |> push_navigate(to: ~p"/journey")}
    end
  end

  @impl true
  def handle_event("next", _params, socket) do
    case validate_step(socket.assigns.step, socket.assigns) do
      :ok -> {:noreply, assign(socket, step: min(socket.assigns.step + 1, 6))}
      {:error, message} -> {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("back", _params, socket),
    do: {:noreply, assign(socket, step: max(socket.assigns.step - 1, 0))}

  def handle_event("save_draft", _params, socket) do
    {:noreply,
     put_flash(socket, :info, "Your trip draft is saved. You can return using this browser.")}
  end

  def handle_event("update_trip_details", %{"trip" => attrs}, socket) do
    attrs = normalize_trip_attrs(attrs)
    update_trip(socket, attrs)
  end

  def handle_event("set_province", %{"province" => province}, socket) do
    socket =
      case Trips.update_trip(
             socket.assigns.current_scope,
             socket.assigns.trip.id,
             socket.assigns.guest_token,
             %{
               starting_province: province,
               starting_district: nil
             }
           ) do
        {:ok, trip} ->
          socket
          |> assign(
            trip:
              Trips.get_trip(socket.assigns.current_scope, trip.id, socket.assigns.guest_token)
          )
          |> assign(province: province, district: "", districts: CxtRoad.list_districts(province))
          |> clear_providers()

        {:error, _} ->
          put_flash(socket, :error, "Could not save the starting province.")
      end

    {:noreply, socket}
  end

  def handle_event("set_district", %{"district" => district}, socket) do
    case Trips.update_trip(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           %{
             starting_district: district
           }
         ) do
      {:ok, trip} ->
        socket =
          socket
          |> assign(
            trip:
              Trips.get_trip(socket.assigns.current_scope, trip.id, socket.assigns.guest_token)
          )
          |> assign(district: district, selected_provider: nil)
          |> load_providers(socket.assigns.transport, district)

        {:noreply, socket}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not save the starting district.")}
    end
  end

  def handle_event(
        "set_destination_location",
        %{"province" => province, "district" => district},
        socket
      ) do
    update_trip(socket, %{destination_province: province, destination_district: district})
  end

  def handle_event("set_transport", %{"transport" => mode}, socket) do
    segments = if mode == "mixed", do: [], else: [%{mode: mode}]

    case Trips.save_transport_segments(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           segments
         ) do
      {:ok, _} ->
        socket =
          socket
          |> assign(
            transport: mode,
            selected_provider: nil,
            road_providers: [],
            air_providers: []
          )
          |> refresh_trip()
          |> then(fn s ->
            if s.assigns.district != "", do: load_providers(s, mode, s.assigns.district), else: s
          end)

        {:noreply, socket}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not save transport selection.")}
    end
  end

  def handle_event("set_transport_estimate", %{"amount" => amount}, socket) do
    case Decimal.parse(amount) do
      {value, ""} ->
        if Decimal.compare(value, Decimal.new(0)) != :lt do
          mode =
            if socket.assigns.transport == "solo",
              do: "private_vehicle",
              else: socket.assigns.transport

          segment = %{
            mode: mode,
            estimated_cost: value,
            notes: "Visitor entered transport estimate"
          }

          case Trips.save_transport_segments(
                 socket.assigns.current_scope,
                 socket.assigns.trip.id,
                 socket.assigns.guest_token,
                 [segment]
               ) do
            {:ok, _} ->
              {:noreply, refresh_trip(socket)}

            {:error, _} ->
              {:noreply, put_flash(socket, :error, "Could not save transport estimate.")}
          end
        else
          {:noreply, put_flash(socket, :error, "Enter a valid non-negative transport estimate.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Enter a valid non-negative transport estimate.")}
    end
  end

  def handle_event("set_provider", %{"provider" => id, "kind" => kind}, socket) do
    provider_id = String.to_integer(id)

    mode =
      if kind == "air",
        do: "air",
        else: if(socket.assigns.transport == "bus", do: "bus", else: "road")

    existing =
      if socket.assigns.transport == "mixed", do: socket.assigns.trip.transport_segments, else: []

    existing =
      Enum.reject(existing, fn segment ->
        if kind == "air", do: not is_nil(segment.airline_id), else: not is_nil(segment.road_id)
      end)

    segment =
      if kind == "air",
        do: %{mode: mode, airline_id: provider_id},
        else: %{mode: mode, road_id: provider_id}

    case Trips.save_transport_segments(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           existing |> Enum.map(&segment_attrs/1) |> Kernel.++([segment])
         ) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(selected_provider: id)
         |> refresh_trip()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not save transport provider.")}
    end
  end

  def handle_event("set_ceremony", %{"ceremony" => "none"}, socket), do: save_event(socket, nil)

  def handle_event("set_ceremony", %{"ceremony" => id}, socket) do
    case Integer.parse(id) do
      {event_id, ""} -> save_event(socket, event_id)
      _ -> {:noreply, put_flash(socket, :error, "Choose a valid event.")}
    end
  end

  def handle_event("toggle_pin", %{"pin" => raw_id}, socket) do
    id = String.to_integer(raw_id)

    result =
      if id in socket.assigns.active_pins do
        Trips.remove_destination(
          socket.assigns.current_scope,
          socket.assigns.trip.id,
          socket.assigns.guest_token,
          id
        )
      else
        Trips.add_destination(
          socket.assigns.current_scope,
          socket.assigns.trip.id,
          socket.assigns.guest_token,
          id
        )
      end

    case result do
      {:ok, _} ->
        {:noreply, socket |> refresh_trip() |> push_map_update()}

      {:error, reason} ->
        {:noreply,
         put_flash(socket, :error, "Could not update destination selection: #{inspect(reason)}")}
    end
  end

  def handle_event("reorder_destinations", %{"ids" => ids}, socket) do
    case Trips.reorder_destinations(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           ids
         ) do
      {:ok, _} ->
        {:noreply, socket |> refresh_trip() |> push_map_update() |> refresh_itinerary()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Destination order could not be saved.")}
    end
  end

  def handle_event("assign_destination_day", %{"site_id" => id, "day" => day}, socket) do
    case Integer.parse(day) do
      {day_number, ""} ->
        case Trips.assign_destination_day(
               socket.assigns.current_scope,
               socket.assigns.trip.id,
               socket.assigns.guest_token,
               id,
               day_number
             ) do
          {:ok, _} ->
            {:noreply, socket |> refresh_trip() |> refresh_itinerary()}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Could not assign that destination day.")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Enter a valid itinerary day.")}
    end
  end

  def handle_event("update_destination_notes", %{"site_id" => id, "notes" => notes}, socket) do
    case Trips.update_destination_notes(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           id,
           notes
         ) do
      {:ok, _} -> {:noreply, refresh_trip(socket)}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not save destination notes.")}
    end
  end

  def handle_event("filter_sites", %{"search" => search, "category" => category}, socket) do
    {:noreply, assign(socket, site_search: search, site_category: category)}
  end

  def handle_event("toggle_food", %{"food" => raw_id}, socket) do
    id = String.to_integer(raw_id)

    selected =
      if id in socket.assigns.selected_foods,
        do: List.delete(socket.assigns.selected_foods, id),
        else: socket.assigns.selected_foods ++ [id]

    case Trips.save_food_selections(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           selected
         ) do
      {:ok, _} -> {:noreply, socket |> assign(selected_foods: selected) |> refresh_trip()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not save food selections.")}
    end
  end

  def handle_event("toggle_music", %{"music" => raw_id}, socket) do
    id = String.to_integer(raw_id)

    selected =
      if id in socket.assigns.selected_music,
        do: List.delete(socket.assigns.selected_music, id),
        else: socket.assigns.selected_music ++ [id]

    case Trips.save_audio_selections(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           selected
         ) do
      {:ok, _} -> {:noreply, socket |> assign(selected_music: selected) |> refresh_trip()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not save music selections.")}
    end
  end

  def handle_event("set_hotel", %{"hotel" => "none"}, socket) do
    case Trips.clear_accommodation(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token
         ) do
      :ok -> {:noreply, socket |> assign(hotel: nil) |> refresh_trip()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not clear accommodation.")}
    end
  end

  def handle_event("set_hotel", %{"hotel" => hotel_id}, socket) do
    attrs = %{check_in: socket.assigns.trip.start_date, check_out: socket.assigns.trip.end_date}

    case Trips.select_accommodation(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           hotel_id,
           attrs
         ) do
      {:ok, _} ->
        {:noreply, socket |> assign(hotel: String.to_integer(hotel_id)) |> refresh_trip()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not save accommodation selection.")}
    end
  end

  def handle_event("set_traveller_name", %{"name" => name}, socket) do
    update_trip(socket, %{traveller_name: String.slice(name, 0, 80)})
  end

  def handle_event("generate_itinerary", _params, socket) do
    trip =
      Trips.get_trip(
        socket.assigns.current_scope,
        socket.assigns.trip.id,
        socket.assigns.guest_token
      )

    itinerary = ItineraryGenerator.generate(trip)
    {:noreply, assign(socket, itinerary: itinerary, budget: itinerary.budget)}
  end

  def handle_event("generate_pdf", _params, socket) do
    trip =
      Trips.get_trip(
        socket.assigns.current_scope,
        socket.assigns.trip.id,
        socket.assigns.guest_token
      )

    itinerary = ItineraryGenerator.generate(trip)
    {:noreply, assign(socket, itinerary: itinerary, budget: itinerary.budget)}
  end

  def handle_event(_event, _params, socket), do: {:noreply, socket}

  def step_label(step),
    do: Atom.to_string(step) |> String.replace("_", " ") |> String.capitalize()

  def progress_pct(step, steps), do: round(step / (length(steps) - 1) * 100)

  def duration(%Trip{start_date: %Date{} = start_date, end_date: %Date{} = end_date}),
    do: max(Date.diff(end_date, start_date) + 1, 1)

  def duration(%Trip{duration_days: days}) when is_integer(days), do: days
  def duration(_), do: 7

  def filtered_sites(sites, search, category) do
    sites
    |> Enum.filter(fn site -> category == "" or site.category == category end)
    |> Enum.filter(fn site ->
      search == "" or
        Enum.any?(
          [site.name, site.description, site.location],
          &(is_binary(&1) and String.contains?(String.downcase(&1), String.downcase(search)))
        )
    end)
  end

  def money(%Decimal{} = value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(Decimal.to_float(value), precision: 2)

  def money(value) when is_integer(value),
    do: "ZMW " <> Number.Delimit.number_to_delimited(value, precision: 2)

  def money(_), do: "Not available"

  def route_label(from, to), do: route_label_from_result(RouteEstimator.between(from, to))
  def route_label_from_result(%{direct_distance_km: nil}), do: "Direct distance unavailable"

  def route_label_from_result(%{direct_distance_km: km}),
    do: "About #{km} km direct · travel time unavailable"

  def format_time(nil), do: "Time unavailable"
  def format_time(%NaiveDateTime{} = time), do: Calendar.strftime(time, "%H:%M")

  defp load_planner(socket, trip, guest_token) do
    ceremonies = CxtEvent.list_ceremonies()
    sites = CxtSite.list_all_sites()

    map_pins =
      Enum.map(sites, fn site ->
        %{
          id: site.id,
          lat: site.latitude,
          lng: site.longitude,
          image_url: site.image_url,
          description: site.description,
          name: site.name
        }
      end)

    district = trip.starting_district || ""

    transport =
      trip.transport_segments
      |> case do
        [segment] -> segment.mode
        [] -> "road"
        _ -> "mixed"
      end

    socket
    |> assign(:current_scope, socket.assigns.current_scope)
    |> assign(:guest_token, guest_token)
    |> assign(:trip, trip)
    |> assign(:trip_id, trip.id)
    |> assign(:trip_form, to_form(Trip.changeset(trip, %{}), as: :trip))
    |> assign(:destination_form, to_form(%{}))
    |> assign(:destination_districts, CxtRoad.list_districts(trip.destination_province))
    |> assign(:step, 0)
    |> assign(:steps, @steps)
    |> assign(:foods, CxtFood.list_all_foods())
    |> assign(:music, CxtAudio.list_all_audio())
    |> assign(:hotels, CxtAccommodation.list_accommodations())
    |> assign(:pins, sites)
    |> assign(
      :site_categories,
      sites |> Enum.map(& &1.category) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort()
    )
    |> assign(:map_pins, map_pins)
    |> assign(:provinces, CxtRoad.list_provinces())
    |> assign(:districts, CxtRoad.list_districts(district))
    |> assign(:ceremonies, ceremonies)
    |> assign(:province, trip.starting_province || "")
    |> assign(:district, district)
    |> assign(:transport, transport)
    |> assign(:road_providers, [])
    |> assign(:air_providers, [])
    |> assign(:selected_provider, selected_provider(trip.transport_segments))
    |> assign(:ceremony, trip.selected_event_id)
    |> assign(:active_pins, Enum.map(trip.trip_stops, & &1.site_id))
    |> assign(:selected_foods, Enum.map(trip.food_selections, & &1.food_id))
    |> assign(:selected_music, Enum.map(trip.audio_selections, & &1.audio_id))
    |> assign(
      :hotel,
      List.first(trip.accommodation_selections) &&
        List.first(trip.accommodation_selections).accommodation_id
    )
    |> assign(:duration, duration(trip))
    |> assign(:site_search, "")
    |> assign(:site_category, "")
    |> assign(:budget, BudgetCalculator.calculate(trip))
    |> assign(:itinerary, nil)
    |> assign(:pdf_error, nil)
    |> assign(:pdf_ready, false)
    |> assign(:generating_pdf, false)
    |> assign(:draft_saved, true)
  end

  defp update_trip(socket, attrs) do
    case Trips.update_trip(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           attrs
         ) do
      {:ok, _trip} ->
        {:noreply, socket |> refresh_trip() |> assign(:draft_saved, true)}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:trip_form, to_form(changeset, as: :trip))
         |> put_flash(:error, "Please correct the trip details.")}
    end
  end

  defp normalize_trip_attrs(attrs) do
    attrs =
      Map.take(
        attrs,
        ~w(title description start_date end_date starting_province starting_district destination_province destination_district traveller_count duration_days budget_estimate traveller_name)
      )

    with start <- Date.from_iso8601(attrs["start_date"] || ""),
         {days, ""} <- Integer.parse(attrs["duration_days"] || "") do
      case start do
        {:ok, start_date} ->
          Map.put(attrs, "end_date", Date.add(start_date, days - 1) |> Date.to_iso8601())

        _ ->
          attrs
      end
    else
      _ -> attrs
    end
  end

  defp refresh_trip(socket) do
    trip =
      Trips.get_trip(
        socket.assigns.current_scope,
        socket.assigns.trip.id,
        socket.assigns.guest_token
      )

    socket
    |> assign(:trip, trip)
    |> assign(:trip_form, to_form(Trip.changeset(trip, %{}), as: :trip))
    |> assign(:destination_districts, CxtRoad.list_districts(trip.destination_province))
    |> assign(:province, trip.starting_province || "")
    |> assign(:district, trip.starting_district || "")
    |> assign(:districts, CxtRoad.list_districts(trip.starting_province))
    |> assign(:active_pins, Enum.map(trip.trip_stops, & &1.site_id))
    |> assign(:selected_foods, Enum.map(trip.food_selections, & &1.food_id))
    |> assign(:selected_music, Enum.map(trip.audio_selections, & &1.audio_id))
    |> assign(:ceremony, trip.selected_event_id)
    |> assign(
      :hotel,
      List.first(trip.accommodation_selections) &&
        List.first(trip.accommodation_selections).accommodation_id
    )
    |> assign(:duration, duration(trip))
    |> assign(:budget, BudgetCalculator.calculate(trip))
    |> assign(:draft_saved, true)
  end

  defp refresh_itinerary(socket) do
    assign(socket, :itinerary, ItineraryGenerator.generate(socket.assigns.trip))
  end

  defp push_map_update(socket) do
    ordered_sites = Enum.map(socket.assigns.trip.trip_stops, & &1.site_id)

    push_event(socket, "pins_updated", %{
      pins: socket.assigns.map_pins,
      active_pins: ordered_sites,
      sequence: ordered_sites
    })
  end

  defp save_event(socket, event_id) do
    case Trips.update_trip(
           socket.assigns.current_scope,
           socket.assigns.trip.id,
           socket.assigns.guest_token,
           %{selected_event_id: event_id}
         ) do
      {:ok, _} -> {:noreply, socket |> assign(ceremony: event_id) |> refresh_trip()}
      {:error, _} -> {:noreply, put_flash(socket, :error, "Could not save event selection.")}
    end
  end

  defp load_providers(socket, "air", district),
    do:
      assign(socket,
        air_providers: EnrouteHaye.Context.CxtAirLine.list_airlines_from(district),
        road_providers: []
      )

  defp load_providers(socket, "mixed", district),
    do:
      assign(socket,
        air_providers: EnrouteHaye.Context.CxtAirLine.list_airlines_from(district),
        road_providers: CxtRoad.list_roads_from(district)
      )

  defp load_providers(socket, mode, district) when mode in ["road", "bus"],
    do: assign(socket, road_providers: CxtRoad.list_roads_from(district), air_providers: [])

  defp load_providers(socket, _mode, _district),
    do: assign(socket, road_providers: [], air_providers: [])

  defp clear_providers(socket),
    do: assign(socket, road_providers: [], air_providers: [], selected_provider: nil)

  defp selected_provider(segments) do
    case Enum.find(segments, &(&1.road_id || &1.airline_id)) do
      nil -> nil
      segment -> to_string(segment.road_id || segment.airline_id)
    end
  end

  defp segment_attrs(segment) do
    %{
      mode: segment.mode,
      road_id: segment.road_id,
      airline_id: segment.airline_id,
      estimated_cost: segment.estimated_cost,
      notes: segment.notes
    }
  end

  defp validate_step(0, assigns) do
    trip = assigns.trip

    cond do
      is_nil(trip.title) or String.trim(trip.title) == "" ->
        {:error, "Add a title for your trip before continuing."}

      is_nil(trip.starting_province) or is_nil(trip.starting_district) ->
        {:error, "Choose a starting province and district."}

      is_nil(trip.start_date) or is_nil(trip.end_date) ->
        {:error, "Choose both trip dates before continuing."}

      Date.compare(trip.end_date, trip.start_date) == :lt ->
        {:error, "The end date cannot be before the start date."}

      true ->
        :ok
    end
  end

  defp validate_step(2, assigns) do
    if assigns.active_pins == [],
      do: {:error, "Add at least one destination to continue."},
      else: :ok
  end

  defp validate_step(_step, _assigns), do: :ok
end
