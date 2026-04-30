defmodule EnrouteHayeWeb.Unauth.LandingPage do
  use EnrouteHayeWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Discover Zambia | Your Ultimate Travel Guide")
      |> assign(:current_scope , nil)
      |> assign(:provinces, provinces())
      |> assign(:experiences, experiences())
      |> assign(:journey_steps, journey_steps())
      |> assign(:heritage_items, heritage_items())
      |> assign(:stats, stats())
      |> assign(:email, "")

    {:ok, socket}
  end

  def handle_event("subscribe", %{"email" => email}, socket) do
    #subscription logic
    {:noreply, assign(socket, :email, email)}
  end

  defp provinces do
    [
      %{name: "Lusaka", slug: "lusaka", color: "#8B9B5A", highlight: true},
      %{name: "Copperbelt", slug: "copperbelt", color: "#6B8E6B", highlight: false},
      %{name: "North-Western", slug: "north-western", color: "#5C7A6E", highlight: false},
      %{name: "Western", slug: "western", color: "#7A9B7A", highlight: false},
      %{name: "Central", slug: "central", color: "#8FAF8F", highlight: false},
      %{name: "Southern", slug: "southern", color: "#6B8B5A", highlight: false},
      %{name: "Eastern", slug: "eastern", color: "#9BAF6B", highlight: true},
      %{name: "Luapula", slug: "luapula", color: "#7B9BAF", highlight: false},
      %{name: "Northern", slug: "northern", color: "#6B8BAF", highlight: false},
      %{name: "Muchinga", slug: "muchinga", color: "#8B9BAF", highlight: false}
    ]
  end

  defp experiences do
    [
      %{
        id: 1,
        title: "Victoria Falls",
        subtitle: "The Smoke That Thunders",
        category: "Nature & Wildlife",
        image_alt: "/images/sites/victoria_falls.jpg",
        badge: "🌊 Water Wonders"
      },
      %{
        id: 2,
        title: "South Luangwa National Park",
        subtitle: "Africa's greatest game parks",
        category: "Nature & Wildlife",
        image_alt: "Elephants at South Luangwa",
        badge: "🐘 Wildlife"
      },
      %{
        id: 3,
        title: "Kuomboka Ceremony",
        subtitle: "Lozi Tradition",
        category: "Culture & Heritage",
        image_alt: "Kuomboka ceremony",
        badge: "🎭 Culture"
      },
      %{
        id: 4,
        title: "Lirambi Lya Mfwa Ceremony",
        subtitle: "Find out what your title says about you",
        category: "Culture & Heritage",
        image_alt: "Traditional ceremony",
        badge: "🎭 Culture"
      },
      %{
        id: 5,
        title: "Kafue National Park",
        subtitle: "Top landscapes",
        category: "Adventure",
        image_alt: "Kafue National Park sunset",
        badge: "🏕️ Adventure"
      }
    ]
  end

  defp journey_steps do
    [
      %{icon: "🗺️", title: "Curate Itineraries", desc: "Personalised plans with ease and ideas"},
      %{icon: "📍", title: "Top Destinations", desc: "Inspirational places worth every mile"},
      %{icon: "🎭", title: "Events & Ceremonies", desc: "Local dates and cultural calendar"},
      %{icon: "🛏️", title: "Stay Options", desc: "Find lodges that suit your style and budget"},
      %{icon: "🎟️", title: "Book & Enjoy", desc: "Simple booking with no fuss, one-click ease"}
    ]
  end

  defp heritage_items do
    [
      %{title: "Traditional Music", desc: "Listen to our sounds", icon: "🎵"},
      %{title: "Cultural Dances", desc: "Watch and learn more", icon: "💃"},
      %{title: "Photo Gallery", desc: "Moments & places", icon: "📸"}
    ]
  end

  defp stats do
    [
      %{value: "10", label: "Provinces"},
      %{value: "72+", label: "National Parks"},
      %{value: "200+", label: "Cultural Sites"},
      %{value: "50+", label: "Traditions"}
    ]
  end
end
