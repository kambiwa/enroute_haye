defmodule EnrouteHayeWeb.Unauth.Journey do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Context.CxtRoad
  alias EnrouteHaye.Context.CxtAir
  alias EnrouteHaye.Context.CxtFood
  alias EnrouteHaye.Context.CxtSite

  @steps ~w(basics ceremony map food music stay summary)a

  @music [
    %{id: "lwiindi",   emoji: "🥁", name: "Liwaye",            desc: "Tonga traditional rain ceremony drumming"},
    %{id: "lozi",      emoji: "👑", name: "Lozi Royal Songs",  desc: "Sacred songs performed during Kuomboka procession"},
    %{id: "folk",      emoji: "🎵", name: "Ngomalume",         desc: "Soulful acoustic melodies from the riverbanks"},
    %{id: "kalindula", emoji: "🎸", name: "Kalindula Rhythms", desc: "Zambia's iconic 70s bass-heavy pop genre"},
    %{id: "ngoma",     emoji: "🪘", name: "Ngoma Drum Circle", desc: "Ceremonial polyrhythmic percussion"},
    %{id: "chewa",     emoji: "🎺", name: "Chewa Gule Songs",  desc: "Mystical music from the masked Gule Wamkulu dance"}
  ]

  @hotels [
    %{id: "royal",   emoji: "🏰", name: "Country Lodge",        stars: "★★★★★", price: 320, dist: "12km from ceremony", inc: "Breakfast · Pool · Spa"},
    %{id: "kubu",    emoji: "🌿", name: "Royal Dreams",         stars: "★★★★",  price: 145, dist: "3km from ceremony",  inc: "Breakfast · River View"},
    %{id: "lealui",  emoji: "🛖", name: "Lealui Cultural Lodge",stars: "★★★",   price: 85,  dist: "On-site Kuomboka",   inc: "Cultural Immersion · Meals"},
    %{id: "barotse", emoji: "🌅", name: "Liseli Lodge",         stars: "★★★★",  price: 210, dist: "8km from ceremony",  inc: "All-inclusive · Canoe"}
  ]

  # ── Mount ──────────────────────────────────────────────────────────────────

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       current_scope: nil,
       step: 0,
       steps: @steps,

       # Data
       foods:    CxtFood.list_foods(%{"order_by" => %{"sort_field" => "name", "sort_direction" => "asc"}}),
       music:    @music,
       hotels:   @hotels,
       pins:     CxtSite.list_sites(%{"order_by" => %{"sort_field" => "name", "sort_direction" => "asc"}}),
       provinces: CxtRoad.list_provinces(),

       # Step 0 — Departure
       province:          "",
       district:          "",
       districts:         [],
       start_date:        "",
       duration:          7,
       duration_custom:   false,
       transport:         "road",
       road_providers:    [],
       air_providers:     [],
       selected_provider: nil,

       # Step 1 — Ceremony
       ceremony: "kuomboka",

       # Step 2 — Map
       active_pins: ~w(kuomboka market craft scenic),

       # Step 3 — Food
       selected_foods: [],

       # Step 4 — Music
       selected_music: [],

       # Step 5 — Stay
       hotel: nil,

       # Step 6 — Summary / PDF
       traveller_name: "",
       generating_pdf: false,
       pdf_ready:      false,
       pdf_error:      nil
     )}
  end

  # ── Navigation ─────────────────────────────────────────────────────────────

  def handle_event("next", _params, %{assigns: %{step: step, steps: steps}} = socket)
      when step < length(steps) - 1,
      do: {:noreply, assign(socket, step: step + 1)}

  def handle_event("back", _params, %{assigns: %{step: step}} = socket)
      when step > 0,
      do: {:noreply, assign(socket, step: step - 1)}

  def handle_event("back", _params, socket), do: {:noreply, socket}
  def handle_event("next", _params, socket), do: {:noreply, socket}

  # ── Step 0 · Province ──────────────────────────────────────────────────────

  def handle_event("set_province", %{"province" => prov}, socket) do
    {:noreply,
     assign(socket,
       province:          prov,
       district:          "",
       districts:         CxtRoad.list_districts(prov),
       road_providers:    [],
       air_providers:     [],
       selected_provider: nil
     )}
  end

  # ── Step 0 · District ─────────────────────────────────────────────────────

  def handle_event("set_district", %{"district" => dist}, socket) do
    socket =
      socket
      |> assign(district: dist, selected_provider: nil)
      |> load_providers(socket.assigns.transport, dist)

    {:noreply, socket}
  end

  # ── Step 0 · Transport ────────────────────────────────────────────────────

  def handle_event("set_transport", %{"transport" => t}, socket) do
    socket =
      socket
      |> assign(transport: t, selected_provider: nil, road_providers: [], air_providers: [])
      |> then(fn s ->
        if s.assigns.district != "",
          do:   load_providers(s, t, s.assigns.district),
          else: s
      end)

    {:noreply, socket}
  end

  # ── Step 0 · Provider selection ───────────────────────────────────────────

  def handle_event("set_provider", %{"provider" => id}, socket),
    do: {:noreply, assign(socket, selected_provider: id)}

  # ── Step 0 · Date ─────────────────────────────────────────────────────────

  def handle_event("set_date", %{"date" => date}, socket),
    do: {:noreply, assign(socket, start_date: date)}

  # ── Step 0 · Duration (slider) ────────────────────────────────────────────

  def handle_event("set_duration", %{"duration" => d}, socket),
    do: {:noreply, assign(socket, duration: String.to_integer(d), duration_custom: false)}

  # ── Step 0 · Duration (custom input) ─────────────────────────────────────

  def handle_event("set_duration_custom", %{"duration" => d}, socket) do
    case Integer.parse(d) do
      {n, ""} when n >= 1 and n <= 365 ->
        {:noreply, assign(socket, duration: n, duration_custom: true)}
      _ ->
        {:noreply, socket}
    end
  end

  # ── Step 1 · Ceremony ──────────────────────────────────────────────────────

  def handle_event("set_ceremony", %{"ceremony" => c}, socket),
    do: {:noreply, assign(socket, ceremony: c)}

  # ── Step 2 · Map pins ─────────────────────────────────────────────────────

  def handle_event("toggle_pin", %{"pin" => pin_id}, socket) do
    pins =
      if pin_id in socket.assigns.active_pins,
        do:   List.delete(socket.assigns.active_pins, pin_id),
        else: [pin_id | socket.assigns.active_pins]

    {:noreply, assign(socket, active_pins: pins)}
  end

  # ── Step 3 · Food ─────────────────────────────────────────────────────────

  def handle_event("toggle_food", %{"food" => food_id}, socket) do
    food_id = String.to_integer(food_id)

    foods =
      if food_id in socket.assigns.selected_foods,
        do:   List.delete(socket.assigns.selected_foods, food_id),
        else: [food_id | socket.assigns.selected_foods]

    {:noreply, assign(socket, selected_foods: foods)}
  end

  # ── Step 4 · Music ────────────────────────────────────────────────────────

  def handle_event("toggle_music", %{"music" => music_id}, socket) do
    music =
      if music_id in socket.assigns.selected_music,
        do:   List.delete(socket.assigns.selected_music, music_id),
        else: [music_id | socket.assigns.selected_music]

    {:noreply, assign(socket, selected_music: music)}
  end

  # ── Step 5 · Hotel ────────────────────────────────────────────────────────

  def handle_event("set_hotel", %{"hotel" => hotel_id}, socket),
    do: {:noreply, assign(socket, hotel: hotel_id)}

  # ── Step 6 · Traveller name ───────────────────────────────────────────────

  def handle_event("set_traveller_name", %{"name" => name}, socket),
    do: {:noreply, assign(socket, traveller_name: name)}

  # ── Step 6 · Generate PDF ─────────────────────────────────────────────────

  def handle_event("generate_pdf", _params, socket) do
    send(self(), :do_generate_pdf)
    {:noreply, assign(socket, generating_pdf: true, pdf_ready: false, pdf_error: nil)}
  end

  def handle_info(:do_generate_pdf, socket) do
    assigns = socket.assigns
    hotel   = hotel_by_id(assigns.hotels, assigns.hotel)
    total   = estimated_cost(assigns.hotels, assigns.hotel, assigns.duration)

    payload = %{
      province:        assigns.province,
      district:        assigns.district,
      duration:        assigns.duration,
      transport:       assigns.transport,
      start_date:      assigns.start_date,
      selected_provider: assigns.selected_provider,
      ceremony:        assigns.ceremony,
      active_pins:     assigns.active_pins,
      selected_foods:  assigns.selected_foods,
      selected_music:  assigns.selected_music,
      hotel_name:      if(hotel, do: hotel.name,  else: nil),
      hotel_price:     if(hotel, do: hotel.price, else: 120),
      total_cost:      total,
      foods_all:       Enum.map(assigns.foods, &Map.take(&1, [:id, :name])),
      music_all:       Enum.map(assigns.music,  &Map.take(&1, [:id, :name])),
      traveller_name:  if(assigns.traveller_name == "", do: nil, else: assigns.traveller_name)
    }

    token = EnrouteHaye.PDFStore.put(payload)

    {:noreply,
     socket
     |> assign(generating_pdf: false, pdf_ready: true)
     |> push_redirect(to: "/pdf/itinerary/#{token}")}
  end

  # ── Private: load transport providers ────────────────────────────────────

  defp load_providers(socket, "air", district) do
    assign(socket,
      air_providers:  CxtAir.list_airlines_from(district),
      road_providers: []
    )
  end

  defp load_providers(socket, "mixed", district) do
    assign(socket,
      air_providers:  CxtAir.list_airlines_from(district),
      road_providers: CxtRoad.list_roads_from(district)
    )
  end

  defp load_providers(socket, transport, district)
       when transport in ~w(road bus solo) do
    assign(socket,
      road_providers: CxtRoad.list_roads_from(district),
      air_providers:  []
    )
  end

  defp load_providers(socket, _transport, _district), do: socket

  # ── Public helpers (used in template) ────────────────────────────────────

  def step_label(step), do: step |> Atom.to_string() |> String.capitalize()

  def progress_pct(step, steps), do: round(step / (length(steps) - 1) * 100)

  def hotel_by_id(hotels, id), do: Enum.find(hotels, &(&1.id == id))

  def estimated_cost(hotels, hotel_id, duration) do
    hotel     = Enum.find(hotels, &(&1.id == hotel_id))
    per_night = if hotel, do: hotel.price, else: 120
    per_night * duration + 350
  end

  def cost_range(base) do
    low  = round(base * 0.9)
    high = round(base * 1.2 + 50)
    {low, high}
  end

  def format_time(nil), do: "—"
  def format_time(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%H:%M")
end
