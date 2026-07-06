defmodule EnrouteHayeWeb.Unauth.LandingPage do
  use EnrouteHayeWeb, :live_view

  @provinces [
    %{
      id: "lusaka",
      name: "Lusaka Province",
      blurb: "The pulse of modern Zambia, where markets, music and city life meet.",
      attractions: "Kabwata Cultural Village, Lusaka National Museum, Munda Wanga",
      image: "/images/sites/gallary.png"
    },
    %{
      id: "southern",
      name: "Southern Province",
      blurb: "Home to Victoria Falls and the thundering Zambezi.",
      attractions: "Victoria Falls, Lake Kariba, Mosi-oa-Tunya National Park",
      image: "/images/sites/adventure.jpg"
    },
    %{
      id: "western",
      name: "Western Province",
      blurb: "Flood plains, royal barges, and the Kuomboka ceremony.",
      attractions: "Barotse Floodplain, Sioma Ngwezi National Park",
      image: "/images/litunga.jpg"
    },
    %{
      id: "eastern",
      name: "Eastern Province",
      blurb: "Wildlife-rich valleys and the vivid Nc'wala ceremony.",
      attractions: "South Luangwa National Park, Chipata",
      image: "/images/sites/ncwala.png"
    },
    %{
      id: "northern",
      name: "Northern Province",
      blurb: "Waterfalls, lakeshores, and the Mutomboko ceremony.",
      attractions: "Kalambo Falls, Lake Tanganyika, Nsumbu National Park",
      image: "/images/lubemba.jpg"
    },
    %{
      id: "luapula",
      name: "Luapula Province",
      blurb: "Wetlands and waterfalls along the Congo border.",
      attractions: "Lake Bangweulu, Ntumbachushi Falls",
      image: "/images/sites/resort.png"
    },
    %{
      id: "copperbelt",
      name: "Copperbelt Province",
      blurb: "Zambia's industrial heartland with a distinct urban culture.",
      attractions: "Copperbelt Museum, Chembe Bird Sanctuary",
      image: "/images/provinces/copperbelt.jpg"
    },
    %{
      id: "central",
      name: "Central Province",
      blurb: "The agricultural spine of the country, rich in open land.",
      attractions: "Kabwe Mine Museum, Chisamba farmlands",
      image: "/images/provinces/central.jpg"
    },
    %{
      id: "northwestern",
      name: "North-Western Province",
      blurb: "Remote, forested, and home to the Mukanda tradition.",
      attractions: "Zambezi Source, West Lunga National Park",
      image: "/images/provinces/northwestern.jpg"
    },
    %{
      id: "muchinga",
      name: "Muchinga Province",
      blurb: "Escarpments and untouched wilderness in the east.",
      attractions: "North Luangwa National Park, Muchinga Escarpment",
      image: "/images/provinces/muchinga.jpg"
    }
  ]

  @experiences [
    %{
      id: "victoria-falls",
      name: "Victoria Falls",
      category: "Natural Wonder",
      duration: "Half day",
      location: "Livingstone, Southern Province",
      rating: 4.9,
      image: "/images/experiences/victoria-falls.jpg"
    },
    %{
      id: "walking-safari",
      name: "Walking Safari",
      category: "Adventure",
      duration: "Full day",
      location: "South Luangwa National Park",
      rating: 4.8,
      image: "/images/experiences/walking-safari.jpg"
    },
    %{
      id: "traditional-ceremonies",
      name: "Traditional Ceremonies",
      category: "Culture",
      duration: "1–3 days",
      location: "Various provinces",
      rating: 5.0,
      image: "/images/experiences/ceremonies.jpg"
    },
    %{
      id: "river-cruises",
      name: "River Cruises",
      category: "Leisure",
      duration: "2–4 hours",
      location: "Zambezi River",
      rating: 4.7,
      image: "/images/experiences/river-cruise.jpg"
    },
    %{
      id: "mukanda",
      name: "Mukanda Cultural Experience",
      category: "Culture",
      duration: "Half day",
      location: "North-Western Province",
      rating: 4.9,
      image: "/images/experiences/mukanda.jpg"
    },
    %{
      id: "craft-markets",
      name: "Craft Markets",
      category: "Community",
      duration: "2 hours",
      location: "Lusaka & Livingstone",
      rating: 4.6,
      image: "/images/experiences/craft-markets.jpg"
    },
    %{
      id: "local-cuisine",
      name: "Local Cuisine",
      category: "Food",
      duration: "2–3 hours",
      location: "Nationwide",
      rating: 4.8,
      image: "/images/experiences/cuisine.jpg"
    },
    %{
      id: "adventure-tourism",
      name: "Adventure Tourism",
      category: "Adventure",
      duration: "Full day",
      location: "Livingstone",
      rating: 4.7,
      image: "/images/experiences/adventure.jpg"
    }
  ]

  @stories [
    %{
      id: "kuomboka",
      title: "Inside the Kuomboka: A River Procession Like No Other",
      author: "Mutinta Sakala",
      province: "Western Province",
      minutes: 6,
      image: "/images/stories/kuomboka.jpg"
    },
    %{
      id: "weavers",
      title: "The Weavers of Barotseland: Patterns That Outlive Their Makers",
      author: "Chanda Mwila",
      province: "Western Province",
      minutes: 8,
      image: "/images/stories/weavers.jpg"
    },
    %{
      id: "luangwa-guides",
      title: "The Last Apprentice Guides of the Luangwa Valley",
      author: "Bwalya Chishimba",
      province: "Eastern Province",
      minutes: 5,
      image: "/images/stories/luangwa.jpg"
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Enroute Home")
     |> assign(:mobile_menu_open, false)
     |> assign(:current_scope, "")
     |> assign(:active_province, nil)
     |> assign(:newsletter_form, to_form(%{email: ""}, as: "newsletter"))
     |> assign(:newsletter_status, nil)
     |> assign(:contact_form, to_form(%{name: "", email: "", subject: "", message: ""}, as: "contact"))
     |> assign(:contact_status, nil)
     |> assign(:provinces, @provinces)
     |> assign(:experiences, @experiences)
     |> assign(:stories, @stories)}
  end

  @impl true
  def handle_event("toggle_mobile_menu", _params, socket) do
    {:noreply, update(socket, :mobile_menu_open, &(!&1))}
  end

  def handle_event("close_mobile_menu", _params, socket) do
    {:noreply, assign(socket, :mobile_menu_open, false)}
  end

  def handle_event("hover_province", %{"id" => id}, socket) do
    {:noreply, assign(socket, :active_province, id)}
  end

  def handle_event("unhover_province", _params, socket) do
    {:noreply, assign(socket, :active_province, nil)}
  end

  def handle_event("newsletter_submit", %{"newsletter" => %{"email" => email}}, socket) do
    if valid_email?(email) do
      # TODO: persist subscriber, e.g. Enroute.Newsletter.subscribe(email)
      {:noreply,
       socket
       |> assign(:newsletter_status, :success)
       |> assign(:newsletter_form, to_form(%{email: ""}, as: "newsletter"))}
    else
      {:noreply, assign(socket, :newsletter_status, :error)}
    end
  end

  def handle_event("contact_submit", %{"contact" => params}, socket) do
    # TODO: persist/send via Enroute.Contact.send_message(params)
    _ = params

    {:noreply,
     socket
     |> assign(:contact_status, :success)
     |> assign(:contact_form, to_form(%{name: "", email: "", subject: "", message: ""}, as: "contact"))}
  end

  defp valid_email?(email) when is_binary(email) do
    String.match?(email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end

  defp valid_email?(_), do: false
end
