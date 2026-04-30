defmodule EnrouteHayeWeb.Unauth.LikumbiLyaMize do
  use EnrouteHayeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Likumbi Lya Mize — The Makishi Awakening")
      |> assign(:current_scope, nil)
      |> assign(:timeline_events, timeline_events())
      |> assign(:makishi_details, makishi_details())
      |> assign(:active_makishi, "mwana_pwo")
      |> assign(:mobile_menu_open, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_makishi", %{"type" => type}, socket) do
    {:noreply, assign(socket, :active_makishi, type)}
  end

  @impl true
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, !socket.assigns.mobile_menu_open)}
  end

  @impl true
  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end

  defp makishi_details do
    [
      %{
        id: "mwana_pwo",
        icon: "grace",
        title: "Mwana Pwo",
        description:
          "The ancestral female spirit, Mwana Pwo embodies grace, femininity, and the beauty of womanhood. Her mask features delicate facial markings and her dance teaches young initiates the virtues of patience and elegance."
      },
      %{
        id: "chihongo",
        icon: "power",
        title: "Chihongo",
        description:
          "The most powerful of all Makishi, Chihongo represents wealth, power, and the blessing of prosperity. Only performed by the chief's family, his appearance commands silence and reverence from the entire gathering."
      },
      %{
        id: "chikunza",
        icon: "ceremony",
        title: "Chikunza",
        description:
          "The master of ceremonies and guardian of the Mukanda initiation. Chikunza oversees the graduation rites, ensuring every initiate is properly received into manhood under the watchful eyes of the ancestors."
      }
    ]
  end

  defp timeline_events do
    [
      %{
        time: "DAWN",
        title: "The Awakening",
        description:
          "Cool mist hangs over Mize village as the first drumbeats ripple through the forest. Families gather at the edge of the ceremonial ground, their breath visible in the early air, anticipation building with every strike of the drum.",
        image: "/images/llm_dawn.jpg",
        image_alt: "Dawn over Mize village",
        align: :right
      },
      %{
        time: "MORNING",
        title: "Emergence of the Makishi",
        description:
          "From the sacred forest they come — towering masked figures adorned in bark-cloth and vivid pigments. The crowd surges with awe and reverence as the ancestral spirits of the Luvale people step into the living world.",
        image: "/images/llm_makishi.jpg",
        image_alt: "Makishi emerging from forest",
        align: :left
      },
      %{
        time: "MIDDAY",
        title: "Dances & Performances",
        description:
          "The ceremonial ground transforms into a theatre of colour and rhythm. Mwana Pwo glides with impossible grace, Chihongo commands with thunderous authority, and the crowds respond with ululations that shake the trees.",
        image: "/images/llm_dance.jpg",
        image_alt: "Makishi performances",
        align: :right
      },
      %{
        time: "AFTERNOON",
        title: "Mukanda Graduation",
        description:
          "The moment all has built toward — young initiates emerge as men. Elders place blessings upon their shoulders as the community bears witness to this ancient rite of passage, unchanged across generations.",
        image: "/images/llm_mukanda.jpg",
        image_alt: "Mukanda initiation graduates",
        align: :left
      },
      %{
        time: "EVENING",
        title: "Celebration & Unity",
        description:
          "As firelight replaces sunlight, the ceremony gives way to song, storytelling, and communal joy. Chief Ndungu's presence anchors the celebration, a living thread connecting the Luvale people to their ancestors and future.",
        image: "/images/llm_evening.jpg",
        image_alt: "Evening celebrations",
        align: :right
      }
    ]
  end
end
