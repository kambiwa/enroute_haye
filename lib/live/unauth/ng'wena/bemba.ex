defmodule EnrouteHayeWeb.Unauth.Bemba do
  use EnrouteHayeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Ukusefya Pa Ng'wena — The Bemba Crocodile Ceremony")
      |> assign(:current_scope, nil)
      |> assign(:timeline_events, timeline_events())
      |> assign(:royal_details, royal_details())
      |> assign(:active_detail, "crocodile")
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

  defp royal_details do
    [
      %{
        id: "crocodile",
        icon: "crocodile",
        title: "Ing'wena — The Sacred Crocodile",
        description:
          "The crocodile is the supreme totem of the Chitimukulu clan. When Bemba ancestors reached the Milando River, they found a dead crocodile — a sign from the spirits that they had found their destined homeland. Today, Chitimukulu is carried to the arena on a throne adorned with a papier-mâché crocodile, re-living that sacred moment."
      },
      %{
        id: "migration",
        icon: "migration",
        title: "The Great Migration Re-enactment",
        description:
          "The ceremonial highlight is a theatrical re-enactment of the Bemba journey from Kola (modern-day Angola) through Luba, across the Luapula, Chambeshi, and Kalungu Rivers, to their final settlement at Ng'wena Village — a journey of thousands of miles across central Africa."
      },
      %{
        id: "chitimukulu",
        icon: "crown",
        title: "Mwine Lubemba — Chitimukulu",
        description:
          "Paramount Chief Chitimukulu Kanyanta-Manga II, known as Mwine Lubemba (owner of the Bemba land), presides over 43 chiefdoms. He is sovereign, judge, and keeper of ancestral law. His arrival at the arena — escorted by senior chiefs, warriors, and indunas — is the ceremony's supreme moment."
      }
    ]
  end

  defp timeline_events do
    [
      %{
        time: "SEPTEMBER 14 · KASAMA",
        title: "The Street Carnival",
        description:
          "The celebrations open in Kasama town with a street carnival — a vibrant procession of Bemba cultural groups performing Buomba music, Imfunkuntu dance, and Malaila war chants through the streets. The city becomes a living stage, setting the tone for the days ahead.",
        image: "/images/ukusefya_carnival.jpg",
        image_alt: "Bemba street carnival in Kasama",
        align: :right
      },
      %{
        time: "SEPTEMBER 17 · AMATEMBWE",
        title: "Paying Homage at Kalisha",
        description:
          "At Kalisha, senior indunas and chiefs pay formal homage at Amatembwe — the sacred throne site of the supreme Bemba ruler. Ancestral prayers open the ceremony, invoking the spirits of the great migration and asking for their blessing on the assembled nation.",
        image: "/images/ukusefya_homage.jpg",
        image_alt: "Homage at Amatembwe, Kalisha",
        align: :left
      },
      %{
        time: "SEPTEMBER 18 · MILANDO RIVER",
        title: "Ukusefya Pali Milando",
        description:
          "The pilgrimage arrives at the Milando River Heritage Site — the exact spot where Bemba ancestors discovered a dead crocodile with two stones in its mouth. Elders re-enact the moment of discovery and the ancestral declaration: 'This is the land chosen for us.' A solemn, deeply sacred gathering.",
        image: "/images/ukusefya_milando.jpg",
        image_alt: "Milando River heritage site",
        align: :right
      },
      %{
        time: "SEPTEMBER 19 · NG'WENA VILLAGE",
        title: "The Grand Ceremony",
        description:
          "Hundreds of thousands converge at the Ng'wena Village National Monument for the climax. Chitimukulu arrives on his crocodile throne, escorted by the procession of 43 Bemba kings. The arena erupts with traditional singing, Malaila war dances, speeches from dignitaries, and the narration of Bemba history from its ancient roots.",
        image: "/images/ukusefya_grand.jpg",
        image_alt: "Grand ceremony at Ng'wena Village",
        align: :left
      }
    ]
  end
end
