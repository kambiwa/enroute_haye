defmodule EnrouteHayeWeb.TripPDFController do
  use EnrouteHayeWeb, :controller

  alias EnrouteHaye.Trips
  alias EnrouteHaye.Trips.ItineraryGenerator

  def show(conn, %{"trip_id" => trip_id}) do
    trip =
      Trips.get_trip(conn.assigns[:current_scope], trip_id, get_session(conn, :trip_guest_access))

    if trip do
      itinerary = ItineraryGenerator.generate(trip)

      case render_pdf(itinerary) do
        {:ok, pdf} ->
          filename = "enroute_itinerary_#{slug(trip.title || "trip")}.pdf"

          conn
          |> put_resp_content_type("application/pdf")
          |> put_resp_header("content-disposition", ~s(attachment; filename="#{filename}"))
          |> send_resp(200, pdf)

        {:error, reason} ->
          conn |> put_status(:internal_server_error) |> text("PDF generation failed: #{reason}")
      end
    else
      conn |> put_status(:not_found) |> text("Trip not found or access denied.")
    end
  end

  defp render_pdf(itinerary) do
    case ChromicPDF.print_to_pdf({:html, build_html(itinerary)},
           print_to_pdf: %{
             paperWidth: 8.27,
             paperHeight: 11.69,
             marginTop: 0.55,
             marginBottom: 0.55,
             marginLeft: 0.55,
             marginRight: 0.55,
             printBackground: true
           }
         ) do
      {:ok, encoded} -> {:ok, Base.decode64!(encoded)}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  defp build_html(itinerary) do
    trip = itinerary.trip
    budget = itinerary.budget
    days_html = Enum.map_join(itinerary.days, "", &day_html/1)
    transport_html = Enum.map_join(itinerary.transport, "", &transport_html/1)

    budget_html =
      Enum.map_join(budget.categories, "", fn {category, value} ->
        "<tr><td>#{esc(category)}</td><td>#{money(value.amount, budget.currency)}</td><td>#{if(value.missing == [], do: "Estimated from recorded prices", else: "Incomplete")}</td></tr>"
      end)

    foods_html = Enum.map_join(itinerary.food, "", fn food -> "<li>#{esc(food.name)}</li>" end)

    music_html =
      Enum.map_join(itinerary.music, "", fn track ->
        "<li>#{esc(track.title)} — #{esc(track.artist)}</li>"
      end)

    warnings_html =
      Enum.map_join(itinerary.warnings, "", fn warning -> "<li>#{esc(warning)}</li>" end)

    accommodation_html =
      Enum.map_join(itinerary.accommodation, "", fn selection ->
        stay = selection.accommodation

        "<li><strong>#{esc(stay.name)}</strong> — #{esc(stay.location)}; #{money(selection.nightly_price_estimate || stay.price_per_night, trip.currency)} per night. Dates: #{esc(selection.check_in || trip.start_date)} to #{esc(selection.check_out || trip.end_date)}. Availability is not confirmed.</li>"
      end)

    event =
      if trip.selected_event,
        do: "#{esc(trip.selected_event.title)} — #{esc(trip.selected_event.location)}",
        else: "No event selected"

    location =
      [trip.starting_district, trip.starting_province]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    total_status =
      if budget.total_complete?,
        do: "Complete from recorded estimates",
        else: "Incomplete — see missing price notes"

    """
    <!doctype html><html lang="en"><head><meta charset="utf-8"><title>#{esc(trip.title)}</title>
    <style>
      *{box-sizing:border-box}body{font-family:Arial,sans-serif;color:#202329;font-size:11px;line-height:1.55;margin:0}
      header{background:#202329;color:#fff;padding:28px 34px;border-bottom:6px solid #D96D38}
      .brand{color:#D96D38;font-size:10px;letter-spacing:3px;font-weight:bold;text-transform:uppercase}
      h1{font-size:27px;margin:10px 0 2px}header p{color:#d9dee3;margin:3px 0}
      main{padding:22px 34px}.overview{display:grid;grid-template-columns:repeat(3,1fr);gap:9px}
      .tile{padding:10px;background:#F5F6F7;border:1px solid #E0E3E6;border-radius:8px}
      .label{font-size:8px;text-transform:uppercase;letter-spacing:1px;color:#647080}.value{font-weight:bold;margin-top:3px}
      h2{font-size:15px;margin:22px 0 8px;color:#202329;border-bottom:2px solid #D96D38;padding-bottom:5px}
      h3{font-size:12px;margin:0 0 5px}.day{page-break-inside:avoid;border:1px solid #E0E3E6;border-radius:8px;margin:10px 0;padding:12px}
      .stop{margin:8px 0 8px 10px;padding-left:10px;border-left:2px solid #BFEDE4}
      .muted{color:#647080}.note{background:#F4D5C5;padding:10px;border-radius:6px}
      table{width:100%;border-collapse:collapse}td,th{text-align:left;padding:7px;border-bottom:1px solid #E0E3E6}th{font-size:8px;text-transform:uppercase;color:#647080}
      .total{font-size:18px;font-weight:bold;color:#D96D38}.page-foot{margin-top:22px;border-top:1px solid #E0E3E6;padding-top:8px;color:#647080;font-size:9px}
    </style></head><body>
      <header><div class="brand">Enroute Haye · Zambia</div><h1>#{esc(trip.title)}</h1><p>#{esc(location)} · #{esc(trip.start_date || "Dates to be confirmed")} – #{esc(trip.end_date || "Dates to be confirmed")}</p><p>#{trip.traveller_count} traveller(s) · #{itinerary.overview.duration_days} day(s) · Draft itinerary</p></header>
      <main>
        <h2>Trip overview</h2><div class="overview">
          <div class="tile"><div class="label">Starting location</div><div class="value">#{esc(location || "Not set")}</div></div>
          <div class="tile"><div class="label">Destination area</div><div class="value">#{esc([trip.destination_district, trip.destination_province] |> Enum.reject(&is_nil/1) |> Enum.join(", ") |> empty_fallback("Not specified"))}</div></div>
          <div class="tile"><div class="label">Event</div><div class="value">#{event}</div></div>
        </div>
        <h2>Transport</h2>#{if transport_html == "", do: "<p>Transport not selected.</p>", else: transport_html}
        <h2>Day-by-day plan</h2>#{if days_html == "", do: "<p>Trip dates are needed to create itinerary days.</p>", else: days_html}
        <h2>Accommodation</h2><ul>#{if accommodation_html == "", do: "<li>No accommodation selected.</li>", else: accommodation_html}</ul>
        <h2>Food and music</h2><div class="overview"><div class="tile"><strong>Selected food</strong><ul>#{if foods_html == "", do: "<li>None selected</li>", else: foods_html}</ul></div><div class="tile"><strong>Music</strong><ul>#{if music_html == "", do: "<li>None selected</li>", else: music_html}</ul></div></div>
        <h2>Estimated budget · #{esc(budget.currency)}</h2><table><thead><tr><th>Category</th><th>Known estimate</th><th>Price status</th></tr></thead><tbody>#{budget_html}</tbody></table>
        <p class="total">Known subtotal: #{money(budget.known_total, budget.currency)}</p><p>Per traveller: #{money(budget.per_traveller, budget.currency)} · Daily average: #{money(budget.per_day, budget.currency)}</p><p class="note">#{total_status}. Values are estimates, not confirmed quotes or bookings.</p>
        <h2>Planning notes</h2><ul>#{if warnings_html == "", do: "<li>No missing information reported.</li>", else: warnings_html}</ul>
        <footer class="page-foot">Generated #{Date.utc_today()} · Enroute Haye trip planner</footer>
      </main></body></html>
    """
  end

  defp day_html(day) do
    stops =
      Enum.map_join(day.destinations, "", fn item ->
        route =
          if item.route_from_previous,
            do: "<small>#{esc(route_text(item.route_from_previous))}</small>",
            else: ""

        notes = if item.notes, do: "<p class='muted'>#{esc(item.notes)}</p>", else: ""

        "<div class='stop'><h3>#{esc(item.site.name)}</h3><p>#{esc(item.site.description)}</p><p class='muted'>#{esc(item.site.location)}</p>#{route}#{notes}</div>"
      end)

    event =
      if day.event,
        do: "<p><strong>Event:</strong> #{esc(day.event.title)} — #{esc(day.event.location)}</p>",
        else: ""

    foods =
      if day.food == [],
        do: "",
        else: "<p><strong>Food:</strong> #{Enum.map_join(day.food, ", ", &esc(&1.name))}</p>"

    stay =
      if day.accommodation,
        do: "<p><strong>Stay:</strong> #{esc(day.accommodation.accommodation.name)}</p>",
        else: ""

    "<article class='day'><h3>Day #{day.number} · #{esc(day.date || "Date to be confirmed")}</h3>#{if stops == "", do: "<p>Travel or free day.</p>", else: stops}#{event}#{foods}#{stay}<p class='muted'>Average known daily estimate: #{money(day.estimated_daily_budget, "ZMW")}</p></article>"
  end

  defp transport_html(segment) do
    provider =
      cond do
        segment.road ->
          "#{segment.road.operator}: #{segment.road.route} (#{segment.road.departure_point} → #{segment.road.arrival_point})"

        segment.airline ->
          "#{segment.airline.airline_name} #{segment.airline.flight_number} (#{segment.airline.departure_district} → #{segment.airline.arrival})"

        true ->
          "No provider selected"
      end

    "<p><strong>#{esc(String.replace(segment.mode, "_", " "))}:</strong> #{esc(provider)} · #{money(segment.estimated_cost || (segment.road && segment.road.price) || (segment.airline && segment.airline.price), "ZMW")} <span class='muted'>Recorded details; availability not live.</span></p>"
  end

  defp route_text(%{direct_distance_km: nil}),
    do: "Direct distance unavailable; travel time unavailable."

  defp route_text(%{direct_distance_km: distance}),
    do: "About #{distance} km direct; this is not a driving route and travel time is unavailable."

  defp money(nil, _currency), do: "Unavailable"

  defp money(%Decimal{} = amount, currency),
    do: "#{currency} #{Decimal.to_string(amount, :normal)}"

  defp money(amount, currency) when is_number(amount), do: "#{currency} #{amount}"
  defp money(_, _currency), do: "Unavailable"

  defp esc(nil), do: ""
  defp esc(%Date{} = value), do: value |> Date.to_iso8601() |> esc()
  defp esc(value) when is_atom(value), do: value |> Atom.to_string() |> esc()
  defp esc(value), do: Phoenix.HTML.html_escape(to_string(value)) |> Phoenix.HTML.safe_to_string()

  defp empty_fallback("", fallback), do: fallback
  defp empty_fallback(value, _fallback), do: value

  defp slug(value) do
    value
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "_")
    |> String.trim("_")
    |> case do
      "" -> "trip"
      slug -> slug
    end
  end
end
