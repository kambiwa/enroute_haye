defmodule EnrouteHayeWeb.Unauth.Home do
  use EnrouteHayeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Kuomboka — The Royal Journey")
      |> assign(:current_scope, nil)
      |> assign(:timeline_events, timeline_events())
      |> assign(:barge_details, barge_details())
      |> assign(:active_detail, "masthead")
      |> assign(:mobile_menu_open, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_detail", %{"type" => type}, socket) do
    {:noreply, assign(socket, :active_detail, type)}
  end

  @impl true
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, !socket.assigns.mobile_menu_open)}
  end

  @impl true
  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end

  defp barge_details do
    [
      %{
        id: "masthead",
        icon: "crown",
        title: "Elephant Masthead",
        description:
          "The barge features a giant elephant head with ears that flap in the wind, symbolizing the strength and wisdom of the Litunga. The elephant is the royal emblem."
      },
      %{
        id: "paddlers",
        icon: "users",
        title: "Royal Paddlers",
        description:
          "Over 100 highly trained paddlers in traditional attire propel the barge. They perform synchronized rowing to the rhythm of royal drums."
      },
      %{
        id: "cabin",
        icon: "castle",
        title: "Royal Cabin",
        description:
          "An enclosed cabin shelters the Litunga from the elements. It is decorated with traditional Lozi patterns and the royal colors of red and black."
      }
    ]
  end

  defp timeline_events do
    [
      %{
        time: "DAWN",
        icon: "sunrise",
        title: "The Royal Drums Awaken",
        description:
          "Maoma royal drums begin their thunderous call across the flood plains, signaling the start of the journey. The sound carries for miles, calling all Lozi people to witness.",
        image: "/images/maoma.png",
        image_alt: "Royal Drummers",
        align: :right
      },
      %{
        time: "MORNING",
        icon: "anchor",
        title: "Boarding the Nalikwanda",
        description:
          "The Litunga emerges in full royal regalia, accompanied by the Prime Minister and royal attendants. The black barge leads, followed by the white Nalikwanda with its elephant masthead.",
        image: "/images/boarding.png",
        image_alt: "Litunga boarding",
        align: :left
      },
      %{
        time: "AFTERNOON",
        icon: "sailboat",
        title: "The Voyage",
        description:
          "Over 100 paddlers propel the barges across the flooded plains. The rhythmic chanting of \"Kuomboka! Kuomboka!\" echoes across the water as crowds line the banks.",
        image: "/images/voyage.jpg",
        image_alt: "The Voyage",
        align: :right
      },
      %{
        time: "EVENING",
        icon: "home",
        title: "Arrival at Limulunga",
        description:
          "The barges dock at the dry capital. Traditional dances, songs, and celebrations continue late into the night as the Litunga takes residence until the waters recede.",
        image: "/images/the royal steps.jpg",
        image_alt: "Celebration",
        align: :left
      }
    ]
  end
end
