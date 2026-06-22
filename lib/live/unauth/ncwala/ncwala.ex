defmodule EnrouteHayeWeb.Unauth.Ncwala do
  use EnrouteHayeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "N'cwala — The First Fruits Ceremony")
      |> assign(:current_scope, nil)
      |> assign(:timeline_events, timeline_events())
      |> assign(:regalia_details, regalia_details())
      |> assign(:active_detail, "spear")
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

  defp regalia_details do
    [
      %{
        id: "spear",
        icon: "spear",
        title: "The Royal Spear",
        description:
          "The Inkosi carries the sacred spear — a symbol of Ngoni military might and ancestral authority. It is presented first to the spirits before the king partakes of the new harvest."
      },
      %{
        id: "warriors",
        icon: "shield",
        title: "Warrior Regiments",
        description:
          "Thousands of warriors in full battle dress — animal skins, feathered headdresses, and war shields — perform the traditional Ngoni war dance, echoing the march of their Zulu ancestors."
      },
      %{
        id: "firstfruits",
        icon: "grain",
        title: "The First Fruits",
        description:
          "Raw meat and the first crops of the season are presented to the Inkosi. He consumes them ritually to bless the harvest, ensuring prosperity and strength for all Ngoni people."
      }
    ]
  end

  defp timeline_events do
    [
      %{
        time: "DAWN",
        icon: "sunrise",
        title: "The Ancestral Call",
        description:
          "Before first light, the Inkosi and his senior indunas gather at the sacred ground. Prayers are offered to Ngoni ancestors, asking for their blessing upon the new season's harvest and the strength of the nation.",
        image: "/images/ncwala_dawn.jpg",
        image_alt: "Dawn ancestral prayers",
        align: :right
      },
      %{
        time: "MORNING",
        icon: "shield",
        title: "The Warriors Assemble",
        description:
          "Thousands of warriors from across the Eastern Province converge at the royal arena in Mtenguleni. Dressed in full war regalia — skins, feathers, shields — they form regiments and begin the thunderous Ngoni war dance.",
        image: "/images/ncwala_warriors.jpg",
        image_alt: "Ngoni warriors assembling",
        align: :left
      },
      %{
        time: "MIDDAY",
        icon: "crown",
        title: "Presentation to the Inkosi",
        description:
          "The first fruits — raw meat from a freshly slaughtered bull and crops from the new harvest — are brought before Inkosi Mpezeni IV. The king tastes them first, ritually opening the season's bounty to his people.",
        image: "/images/ncwala_inkosi.jpg",
        image_alt: "Presentation to the Inkosi",
        align: :right
      },
      %{
        time: "AFTERNOON",
        icon: "music",
        title: "Dance & Celebration",
        description:
          "The royal arena erupts in song and dance. Women perform the celebratory ingoma, warriors clash their shields in unison, and the beating of drums carries across the Chipata plains as all celebrate the abundance of the new year.",
        image: "/images/ncwala_celebration.jpg",
        image_alt: "N'cwala celebration dances",
        align: :left
      }
    ]
  end
end
