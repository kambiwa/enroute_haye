# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EnrouteHaye.Repo.insert!(%EnrouteHaye.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
# NOTE: This seed file inserts by table name (Repo.insert_all) so it matches the
# migration exactly and does not depend on your schema modules. It is NOT
# idempotent: run it on a fresh database, or run `mix ecto.reset` first.

alias EnrouteHaye.Repo

now_naive = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
now_utc = DateTime.utc_now() |> DateTime.truncate(:second)

# Helpers ---------------------------------------------------------------

# Inserts rows into `table` and returns the list of generated ids (in order).
insert = fn table, rows ->
  {_count, results} = Repo.insert_all(table, rows, returning: [:id])
  Enum.map(results, & &1.id)
end

# Adds timestamps. `:naive` for `timestamps()`, `:utc` for `timestamps(type: :utc_datetime)`.
naive_ts = fn row -> Map.merge(row, %{inserted_at: now_naive, updated_at: now_naive}) end
utc_ts = fn row -> Map.merge(row, %{inserted_at: now_utc, updated_at: now_utc}) end

dec = &Decimal.new/1

# Password hashing (phx.gen.auth default). Swap for Argon2/Pbkdf2 if you use those.
hash = fn password -> Bcrypt.hash_pwd_salt(password) end

# ========================
# WORKFLOW
# ========================
[_wf_trip, _wf_booking] =
  insert.(
    "workflow",
    Enum.map(
      [
        %{
          name: "Trip Approval",
          status: "active",
          description: "Approval flow for submitted trips",
          is_active: true,
          flow: [
            %{"step" => 1, "name" => "Submitted", "role" => "user"},
            %{"step" => 2, "name" => "Review", "role" => "manager"},
            %{"step" => 3, "name" => "Approved", "role" => "admin"}
          ]
        },
        %{
          name: "Booking Confirmation",
          status: "active",
          description: "Flow for confirming accommodation bookings",
          is_active: true,
          flow: [
            %{"step" => 1, "name" => "Pending", "role" => "user"},
            %{"step" => 2, "name" => "Confirmed", "role" => "admin"}
          ]
        }
      ],
      naive_ts
    )
  )

# ========================
# DEPARTMENT
# ========================
[dept_ops, dept_tourism, dept_it] =
  insert.(
    "department",
    Enum.map(
      [
        %{
          name: "Operations",
          description: "Day-to-day operations",
          status: "active",
          is_active: true
        },
        %{
          name: "Tourism",
          description: "Tourism products and partnerships",
          status: "active",
          is_active: true
        },
        %{name: "IT", description: "Systems and support", status: "active", is_active: true}
      ],
      naive_ts
    )
  )

# ========================
# JOB TYPES
# ========================
[jt_full, jt_part, jt_contract] =
  insert.(
    "job_types",
    Enum.map(
      [
        %{title: "Full-time", is_active: true},
        %{title: "Part-time", is_active: true},
        %{title: "Contract", is_active: true}
      ],
      naive_ts
    )
  )

# ========================
# JOBS
# ========================
[job_manager, job_guide, job_dev] =
  insert.(
    "jobs",
    Enum.map(
      [
        %{
          title: "Operations Manager",
          description: "Oversees operations",
          status: "open",
          job_type_id: jt_full,
          department_id: dept_ops,
          is_active: true
        },
        %{
          title: "Tour Guide",
          description: "Leads guided tours",
          status: "open",
          job_type_id: jt_part,
          department_id: dept_tourism,
          is_active: true
        },
        %{
          title: "Software Developer",
          description: "Builds and maintains the platform",
          status: "open",
          job_type_id: jt_contract,
          department_id: dept_it,
          is_active: true
        }
      ],
      naive_ts
    )
  )

# ========================
# USERS
# ========================
[admin_id, manager_id, traveler_id, guide_id] =
  insert.(
    "users",
    Enum.map(
      [
        %{
          email: "dev@dev.com",
          hashed_password: hash.("dev@dev.com"),
          confirmed_at: now_utc,
          name: "Admin User",
          country: "Zambia",
          bio: "Platform administrator.",
          job_id: job_dev,
          role: "admin"
        },
        %{
          email: "manager@enroutehaye.com",
          hashed_password: hash.("password1234"),
          confirmed_at: now_utc,
          name: "Mary Banda",
          country: "Zambia",
          bio: "Operations manager.",
          job_id: job_manager,
          role: "manager"
        },
        %{
          email: "traveler@enroutehaye.com",
          hashed_password: hash.("password1234"),
          confirmed_at: now_utc,
          name: "John Phiri",
          country: "Zambia",
          bio: "Loves exploring new places.",
          job_id: nil,
          role: "user"
        },
        %{
          email: "guide@enroutehaye.com",
          hashed_password: hash.("password1234"),
          confirmed_at: now_utc,
          name: "Chanda Mulenga",
          country: "Zambia",
          bio: "Experienced local guide.",
          job_id: job_guide,
          role: "user"
        }
      ],
      utc_ts
    )
  )

# ========================
# SITES
# ========================
[site_falls, site_lower_zambezi, site_south_luangwa, site_kafue] =
  insert.(
    "sites",
    Enum.map(
      [
        %{
          name: "Victoria Falls (Mosi-oa-Tunya)",
          description: "One of the largest waterfalls in the world, on the Zambezi River.",
          location: "Livingstone",
          latitude: -17.9243,
          longitude: 25.8572,
          category: "nature",
          image_url: "https://example.com/images/victoria-falls.jpg",
          price: 50,
          status: "active"
        },
        %{
          name: "Lower Zambezi National Park",
          description: "Wildlife-rich park along the Zambezi escarpment.",
          location: "Lower Zambezi",
          latitude: -15.5000,
          longitude: 29.2000,
          category: "wildlife",
          image_url: "https://example.com/images/lower-zambezi.jpg",
          price: 30,
          status: "active"
        },
        %{
          name: "South Luangwa National Park",
          description: "Famous for walking safaris and leopard sightings.",
          location: "Mfuwe",
          latitude: -13.0000,
          longitude: 31.5000,
          category: "wildlife",
          image_url: "https://example.com/images/south-luangwa.jpg",
          price: 40,
          status: "active"
        },
        %{
          name: "Kafue National Park",
          description: "Zambia's largest national park.",
          location: "Kafue",
          latitude: -15.5833,
          longitude: 25.8333,
          category: "wildlife",
          image_url: "https://example.com/images/kafue.jpg",
          price: 25,
          status: "active"
        }
      ],
      utc_ts
    )
  )

# ========================
# FOODS
# ========================
insert.(
  "foods",
  Enum.map(
    [
      %{
        name: "Nshima with Kapenta",
        description: "Zambian staple of maize meal served with small dried fish.",
        price: dec.("4.50"),
        image_url: "https://example.com/images/nshima-kapenta.jpg"
      },
      %{
        name: "Ifisashi",
        description: "Leafy greens cooked in a groundnut sauce.",
        price: dec.("3.75"),
        image_url: "https://example.com/images/ifisashi.jpg"
      },
      %{
        name: "Village Chicken",
        description: "Free-range chicken slow cooked with tomatoes and onions.",
        price: dec.("7.00"),
        image_url: "https://example.com/images/village-chicken.jpg"
      }
    ],
    utc_ts
  )
)

# ========================
# TRIPS
# ========================
[trip_south, trip_north] =
  insert.(
    "trips",
    Enum.map(
      [
        %{
          title: "Southern Province Adventure",
          description: "A 3-day trip to Livingstone and Victoria Falls.",
          start_date: ~D[2026-11-10],
          end_date: ~D[2026-11-12],
          budget_estimate: dec.("750.00"),
          status: "draft",
          user_id: traveler_id
        },
        %{
          title: "Safari Escape",
          description: "Wildlife safari in South Luangwa.",
          start_date: ~D[2026-12-05],
          end_date: ~D[2026-12-08],
          budget_estimate: dec.("1500.00"),
          status: "confirmed",
          user_id: traveler_id
        }
      ],
      utc_ts
    )
  )

# ========================
# TRIP STOPS
# ========================
insert.(
  "trip_stops",
  Enum.map(
    [
      %{
        day_number: 1,
        order_index: 1,
        notes: "Arrive and check in.",
        trip_id: trip_south,
        site_id: site_falls
      },
      %{
        day_number: 2,
        order_index: 1,
        notes: "Guided tour of the falls.",
        trip_id: trip_south,
        site_id: site_falls
      },
      %{
        day_number: 1,
        order_index: 1,
        notes: "Morning game drive.",
        trip_id: trip_north,
        site_id: site_south_luangwa
      },
      %{
        day_number: 2,
        order_index: 1,
        notes: "Walking safari.",
        trip_id: trip_north,
        site_id: site_south_luangwa
      }
    ],
    utc_ts
  )
)

# ========================
# EVENTS
# ========================
insert.(
  "events",
  Enum.map(
    [
      %{
        title: "Kuomboka Ceremony",
        type: "cultural",
        description: "Traditional ceremony of the Lozi people of Western Province.",
        start_date: ~N[2027-03-27 09:00:00],
        end_date: ~N[2027-03-27 17:00:00],
        location: "Limulunga",
        latitude: -15.2833,
        longitude: 23.1500,
        image_url: "https://example.com/images/kuomboka.jpg"
      },
      %{
        title: "Livingstone Food and Music Festival",
        type: "festival",
        description: "Weekend of local food, music and crafts.",
        start_date: ~N[2026-11-20 10:00:00],
        end_date: ~N[2026-11-22 22:00:00],
        location: "Livingstone",
        latitude: -17.8419,
        longitude: 25.8544,
        image_url: "https://example.com/images/festival.jpg"
      }
    ],
    utc_ts
  )
)

# ========================
# ACCOMMODATIONS
# ========================
[acc_livingstone, acc_mfuwe] =
  insert.(
    "accommodations",
    Enum.map(
      [
        %{
          name: "Zambezi Riverside Lodge",
          description: "Riverside lodge close to Victoria Falls.",
          location: "Livingstone",
          latitude: -17.8500,
          longitude: 25.8600,
          price_per_night: dec.("120.00"),
          rating: 4.5,
          contact_email: "info@zambezilodge.example.com",
          contact_phone: "+260 97 1000001",
          image_url: "https://example.com/images/zambezi-lodge.jpg"
        },
        %{
          name: "Luangwa Bush Camp",
          description: "Tented camp on the banks of the Luangwa River.",
          location: "Mfuwe",
          latitude: -13.0300,
          longitude: 31.7500,
          price_per_night: dec.("200.00"),
          rating: 4.8,
          contact_email: "stay@luangwacamp.example.com",
          contact_phone: "+260 97 1000002",
          image_url: "https://example.com/images/luangwa-camp.jpg"
        }
      ],
      utc_ts
    )
  )

# ========================
# BOOKINGS
# ========================
insert.(
  "bookings",
  Enum.map(
    [
      %{
        check_in: ~D[2026-11-10],
        check_out: ~D[2026-11-12],
        total_price: dec.("240.00"),
        status: "pending",
        user_id: traveler_id,
        accommodation_id: acc_livingstone
      },
      %{
        check_in: ~D[2026-12-05],
        check_out: ~D[2026-12-08],
        total_price: dec.("600.00"),
        status: "confirmed",
        user_id: traveler_id,
        accommodation_id: acc_mfuwe
      }
    ],
    utc_ts
  )
)

# ========================
# AUDIO
# ========================
insert.(
  "audio",
  Enum.map(
    [
      %{
        title: "Sounds of the Zambezi",
        artist: "Nature Recordings",
        description: "Ambient audio recorded along the Zambezi River.",
        file_url: "https://example.com/audio/zambezi.mp3",
        duration: 360,
        cover_image: "https://example.com/images/audio-zambezi.jpg",
        category: "ambient"
      },
      %{
        title: "Welcome to Zambia",
        artist: "Enroute Haye",
        description: "Audio introduction for first-time visitors.",
        file_url: "https://example.com/audio/welcome.mp3",
        duration: 180,
        cover_image: "https://example.com/images/audio-welcome.jpg",
        category: "guide"
      }
    ],
    utc_ts
  )
)

# ========================
# MEDIA
# ========================
insert.(
  "media",
  Enum.map(
    [
      %{
        title: "Victoria Falls from Above",
        media_type: "video",
        author: "Enroute Haye",
        category: "documentary",
        description: "Aerial look at Victoria Falls.",
        location: "Livingstone",
        file_path: "/uploads/media/victoria-falls.mp4",
        minutes: 12,
        poster_path: "/uploads/posters/victoria-falls.jpg"
      },
      %{
        title: "Safari Diaries",
        media_type: "video",
        author: "Enroute Haye",
        category: "travel",
        description: "A week on safari in South Luangwa.",
        location: "Mfuwe",
        file_path: "/uploads/media/safari-diaries.mp4",
        minutes: 25,
        poster_path: "/uploads/posters/safari-diaries.jpg"
      }
    ],
    utc_ts
  )
)

# ========================
# ROADS
# ========================
insert.(
  "roads",
  Enum.map(
    [
      %{
        operator: "Mazhandu Family Bus Services",
        route: "Lusaka - Livingstone",
        departure_point: "Intercity Bus Terminal, Lusaka",
        arrival_point: "Livingstone Bus Station",
        departure_time: ~N[2026-11-10 06:00:00],
        arrival_time: ~N[2026-11-10 14:00:00],
        price: dec.("45.00"),
        operator_contact: "+260 97 2000001"
      },
      %{
        operator: "Power Tools Bus Services",
        route: "Lusaka - Chipata",
        departure_point: "Intercity Bus Terminal, Lusaka",
        arrival_point: "Chipata Bus Station",
        departure_time: ~N[2026-12-04 07:00:00],
        arrival_time: ~N[2026-12-04 16:00:00],
        price: dec.("40.00"),
        operator_contact: "+260 97 2000002"
      }
    ],
    utc_ts
  )
)

# ========================
# AIRLINE
# ========================
insert.(
  "airline",
  Enum.map(
    [
      %{
        airline_name: "Proflight Zambia",
        flight_number: "P0 101",
        departure_district: "Lusaka",
        arrival: "Livingstone",
        departure_time: ~N[2026-11-10 08:00:00],
        arrival_time: ~N[2026-11-10 09:15:00],
        price: dec.("180.00"),
        airline_contact: "+260 97 3000001"
      },
      %{
        airline_name: "Proflight Zambia",
        flight_number: "P0 202",
        departure_district: "Lusaka",
        arrival: "Mfuwe",
        departure_time: ~N[2026-12-05 07:30:00],
        arrival_time: ~N[2026-12-05 09:00:00],
        price: dec.("220.00"),
        airline_contact: "+260 97 3000001"
      }
    ],
    utc_ts
  )
)

# ========================
# REVIEWS
# ========================
insert.(
  "reviews",
  Enum.map(
    [
      %{
        rating: 5,
        comment: "Beautiful location and friendly staff.",
        user_id: traveler_id,
        accommodation_id: acc_livingstone
      },
      %{
        rating: 4,
        comment: "Great game drives, tents were comfortable.",
        user_id: guide_id,
        accommodation_id: acc_mfuwe
      }
    ],
    utc_ts
  )
)

# ========================
# FAVORITES
# ========================
insert.(
  "favorites",
  Enum.map(
    [
      %{user_id: traveler_id, site_id: site_falls},
      %{user_id: traveler_id, site_id: site_south_luangwa},
      %{user_id: guide_id, site_id: site_kafue},
      %{user_id: manager_id, site_id: site_lower_zambezi}
    ],
    utc_ts
  )
)

# ========================
# NOTIFICATIONS
# ========================
insert.(
  "notifications",
  Enum.map(
    [
      %{
        status: "unread",
        type: "booking",
        message: "Your booking at Zambezi Riverside Lodge is pending confirmation.",
        read: false,
        action_url: "/bookings",
        sender_name: "Admin User",
        document_name: "Booking",
        document_id: "1",
        comments: "Please wait for confirmation.",
        user_id: traveler_id,
        sender_id: admin_id
      },
      %{
        status: "unread",
        type: "trip",
        message: "A new trip is awaiting your review.",
        read: false,
        action_url: "/trips",
        sender_name: "John Phiri",
        document_name: "Trip",
        document_id: "1",
        comments: "Southern Province Adventure",
        user_id: manager_id,
        sender_id: traveler_id
      }
    ],
    naive_ts
  )
)

IO.puts("Seeding complete.")
