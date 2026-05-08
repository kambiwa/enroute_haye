defmodule EnrouteHayeWeb.Unauth.LandingPage do
  use EnrouteHayeWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Discover Zambia | Your Ultimate Travel Guide")
      |> assign(:current_scope, nil)
      |> assign(:provinces, provinces())
      |> assign(:experiences, experiences())
      |> assign(:journey_steps, journey_steps())
      |> assign(:heritage_items, heritage_items())
      |> assign(:stats, stats())
      |> assign(:email, "")

    {:ok, socket}
  end

  def handle_event("subscribe", %{"email" => email}, socket) do
    # subscription logic
    {:noreply, assign(socket, :email, email)}
  end

  defp provinces do
    [
      %{name: "Lusaka",        slug: "lusaka",        color: "#8B9B5A", highlight: true},
      %{name: "Copperbelt",    slug: "copperbelt",    color: "#6B8E6B", highlight: false},
      %{name: "North-Western", slug: "north-western", color: "#5C7A6E", highlight: false},
      %{name: "Western",       slug: "western",       color: "#7A9B7A", highlight: false},
      %{name: "Central",       slug: "central",       color: "#8FAF8F", highlight: false},
      %{name: "Southern",      slug: "southern",      color: "#6B8B5A", highlight: false},
      %{name: "Eastern",       slug: "eastern",       color: "#9BAF6B", highlight: true},
      %{name: "Luapula",       slug: "luapula",       color: "#7B9BAF", highlight: false},
      %{name: "Northern",      slug: "northern",      color: "#6B8BAF", highlight: false},
      %{name: "Muchinga",      slug: "muchinga",      color: "#8B9BAF", highlight: false}
    ]
  end

  defp experiences do
    [
      %{
        id: 1,
        title: "Victoria Falls",
        subtitle: "The Smoke That Thunders",
        category: "Nature & Wildlife",
        image_url: "/images/sites/victoria_falls.jpg",
        badge: "🌊 Water Wonders"
      },
      %{
        id: 2,
        title: "South Luangwa National Park",
        subtitle: "Africa's greatest game parks",
        category: "Nature & Wildlife",
        image_url: "/images/sites/South-Luangwa-National-Park.jpg",
        badge: "🐘 Wildlife"
      },
      %{
        id: 3,
        title: "Kuomboka Ceremony",
        subtitle: "Lozi Tradition",
        category: "Culture & Heritage",
        image_url: "/images/the litunga.jpg",
        badge: "🎭 Culture"
      },
      %{
        id: 4,
        title: "Likumbi lya Mize Ceremony",
        subtitle: "Luvale Tradition - Northern Province",
        category: "Culture & Heritage",
        image_url: "/images/mize/mask.jpg",
        badge: "🎭 Culture"
      },
      %{
        id: 5,
        title: "Victoria falls bungee jump",
        subtitle: "Top landscapes",
        category: "Adventure",
        image_url: "/images/sites/adventure.jpg",
        badge: "🏕️ Adventure"
      }
    ]
  end

  defp journey_steps do
    [
      %{
        icon: "🗺️",
        title: "Curate Itineraries",
        desc: "Personalised plans with ease and ideas",
        image_url: "/images/sites/itenerary.png"
      },
      %{
        icon: "📍",
        title: "Top Destinations",
        desc: "Inspirational places worth every mile",
        image_url: "/images/sites/map.png"
      },
      %{
        icon: "🎭",
        title: "Events & Ceremonies",
        desc: "Local dates and cultural calendar",
        image_url: "/images/sites/ncwala.png"
      },
      %{
        icon: "🛏️",
        title: "Stay Options",
        desc: "Find lodges that suit your style and budget",
        image_url: "/images/sites/resort.png"
      },
      %{
        icon: "🎟️",
        title: "Book & Enjoy",
        desc: "Simple booking with no fuss, one-click ease",
        image_url: "/images/sites/camp.png"

      }
    ]
  end

  defp heritage_items do
    [
      %{
        title: "Traditional Music",
        desc: "Listen to our sounds",
        icon: "🎵",
        image_url: "/images/heritage/music.jpg"
      },
      %{
        title: "Cultural Dances",
        desc: "Watch and learn more",
        icon: "💃",
        image_url: "/images/maoma.png"
      },
      %{
        title: "Photo Gallery",
        desc: "Moments & places",
        icon: "📸",
        image_url: "/images/sites/gallary.png"
      }
    ]
  end

  defp stats do
    [
      %{value: "10",   label: "Provinces"},
      %{value: "72+",  label: "National Parks"},
      %{value: "200+", label: "Cultural Sites"},
      %{value: "50+",  label: "Traditions"}
    ]
  end
end
