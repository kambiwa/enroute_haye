defmodule EnrouteHayeWeb.Unauth.Kuomboka do
  use EnrouteHayeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Kuomboka — The Royal Migration")
      |> assign(:current_scope, nil)
      |> assign(:timeline_events, timeline_events())
      |> assign(:regalia_details, regalia_details())
      |> assign(:active_regalia, "nalikwanda")
      |> assign(:mobile_menu_open, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_regalia", %{"type" => type}, socket) do
    {:noreply, assign(socket, :active_regalia, type)}
  end

  @impl true
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, !socket.assigns.mobile_menu_open)}
  end

  @impl true
  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end

  defp regalia_details do
    [
      %{
        id: "nalikwanda",
        icon: "power",
        title: "Nalikwanda",
        description:
          "The Litunga's royal barge, painted in bold black-and-white stripes and crowned with a carved elephant statue. Nalikwanda carries the king, his family, and his regalia safely across the flooded Zambezi plains."
      },
      %{
        id: "maoma",
        icon: "ceremony",
        title: "Maoma Drums",
        description:
          "A set of enormous royal war drums, each bearing its own name and history. Their deep, rolling beat sets the pace for the paddlers and announces the Litunga's progress to villages along the route."
      },
      %{
        id: "njamba",
        icon: "grace",
        title: "Njamba Paddlers",
        description:
          "Over a hundred selected men, dressed in animal-skin skirts and red berets crowned with feathers, paddle the Nalikwanda in perfect rhythm — a display of discipline, strength, and pride in service to the king."
      }
    ]
  end

  defp timeline_events do
    [
      %{
        time: "DAWN",
        title: "Preparation at Lealui",
        description:
          "Before first light, the royal court at Lealui stirs. The Nalikwanda is inspected and loaded, the Litunga's regalia is prepared, and paddlers gather at the water's edge as the floodwaters press closer to the palace.",
        image: "/images/kuomboka/kuomboka_dawn.jpg",
        image_alt: "Dawn preparations at Lealui",
        align: :right
      },
      %{
        time: "MORNING",
        title: "The Litunga Boards",
        description:
          "The Litunga emerges in full ceremonial dress and boards the Nalikwanda beneath a canopy raised in his honour. The Maoma drums begin their deep, rolling call, signalling to the whole floodplain that the migration has begun.",
        image: "/images/kuomboka/kuomboka_departure.jpg",
        image_alt: "The Litunga boarding the Nalikwanda",
        align: :left
      },
      %{
        time: "MIDDAY",
        title: "The Great Crossing",
        description:
          "The Nalikwanda glides across the flooded plains, escorted by smaller barges carrying musicians, family, and Indunas. Crowds line the drier stretches of ground, singing and waving as the royal flotilla passes.",
        image: "/images/kuomboka/kuomboka_crossing.jpg",
        image_alt: "The royal flotilla crossing the floodplain",
        align: :right
      },
      %{
        time: "AFTERNOON",
        title: "Arrival at Limulunga",
        description:
          "As the Nalikwanda nears the raised ground of Limulunga, the pace of the drums quickens and the waiting crowd erupts in celebration. The Litunga disembarks to be received by his people at the flood-season capital.",
        image: "/images/kuomboka/kuomboka_arrival.jpg",
        image_alt: "Arrival of the royal barge at Limulunga",
        align: :left
      },
      %{
        time: "EVENING",
        title: "Celebration at Limulunga",
        description:
          "Night falls on song, dance, and feasting as the Lozi nation marks another successful crossing. The Litunga's presence at Limulunga affirms the continuity of Barotse tradition for another flood season.",
        image: "/images/kuomboka/kuomboka_celebration.jpg",
        image_alt: "Evening celebrations at Limulunga",
        align: :right
      }
    ]
  end
end
