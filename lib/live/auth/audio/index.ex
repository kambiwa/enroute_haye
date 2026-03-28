defmodule EnrouteHayeWeb.Auth.AudioManager.Index do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHayeWeb.Datatable.Table
  alias EnrouteHaye.Schema.Audio
  alias EnrouteHaye.Context.CxtAudio
  alias EnrouteHayeWeb.Pagination
  alias EnrouteHayeWeb.PaginationComponent

  @impl true
  def mount(_params, _session, socket) do
    audio = CxtAudio.list_audios(%{"page_size" => 10}).entries |> List.first()
    socket =
      socket
      |> assign(:page_title, "Audio Manager")
      |> assign(:data_loader, false)
      |> assign(:data, [])
      |> assign(:data_pagenations, [])
      |> assign(filter_expanded: false)
      |> assign(:status_filter, "")
      |> assign(:search_filter, "")
      |> assign(:audio, %Audio{})
      |> assign(:now_playing, nil)
      |> Pagination.order_by_composer()
      |> Pagination.i_search_composer()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(params: %{})
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Audio")
    |> assign(:audio, CxtAudio.get_audio!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Audio")
    |> assign(:audio, %Audio{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Audio Manager")
    |> assign(:audio, nil)
    |> fetch_filtered_audio()
  end

  @impl true
  def handle_info({EnrouteHayeWeb.Audio.FormComponent, {:saved, _audio}}, socket) do
    {:noreply, fetch_filtered_audio(socket)}
  end

  @impl true
  def handle_event("add_audio", _params, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "New Audio")
     |> assign(:audio, %Audio{})
     |> assign(:live_action, :new)}
  end

  def handle_event("edit", %{"id" => id}, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Edit Audio")
     |> assign(:audio, CxtAudio.get_audio!(id))
     |> assign(:live_action, :edit)}
  end

  @impl true
  def handle_event("close", _params, socket) do
    {:noreply, assign(socket, :live_action, :index)}
  end

  @impl true
  def handle_event("toggle-filter", _, socket) do
    {:noreply, assign(socket, filter_expanded: !socket.assigns.filter_expanded)}
  end

  @impl true
  def handle_event("filter", %{"filter" => filters} = _params, socket) do
    {:noreply,
     socket
     |> assign(:status_filter, filters["status_filter"])
     |> assign(:search_filter, filters["search_filter"])
     |> fetch_filtered_audio()}
  end

  @impl true
  def handle_event("play", %{"id" => id}, socket) do
    audio = Enum.find(socket.assigns.data, &(to_string(&1.id) == id))
    {:noreply, assign(socket, :now_playing, audio)}
  end

  defp fetch_filtered_audio(socket) do
    filters = %{
      search_filter: socket.assigns.search_filter,
      status_filter: socket.assigns.status_filter
    }

    data =
      CxtAudio.list_audios(
        Pagination.create_table_params(socket, socket.assigns.params),
        filters
      )

    socket
    |> assign(:data, data.entries)
    |> assign(:data_pagenations, Map.drop(data, [:entries]))
    |> assign(data_loader: false)
  end

  # ── Render ───────────────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_scope={@current_scope} current_page={:audios}>

      <%!-- ══ PLAYER STYLES ══ --%>
      <style>
        @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Sans:wght@300;400;500&display=swap');

        .audio-page { font-family: 'DM Sans', sans-serif; }

        .track-row { transition: background 0.15s; cursor: pointer; }
        .track-row:hover { background: rgba(139,26,26,0.04) !important; }
        .track-row.playing { background: rgba(139,26,26,0.08) !important; }

        .player-bar {
          position: fixed; bottom: 0; left: 0; right: 0; z-index: 100;
          background: #1a0505;
          border-top: 1px solid rgba(139,26,26,0.4);
          backdrop-filter: blur(12px);
          padding: 0.75rem 1.5rem;
          display: flex; align-items: center; gap: 1.5rem;
        }

        .progress-bar-wrap {
          flex: 1; height: 4px; background: rgba(255,255,255,0.12);
          border-radius: 99px; cursor: pointer; position: relative;
        }
        .progress-fill {
          height: 100%; background: #8B1A1A;
          border-radius: 99px; width: 0%;
          transition: width 0.5s linear;
        }
        .progress-bar-wrap:hover .progress-fill { background: #c0392b; }

        .vol-slider {
          -webkit-appearance: none; appearance: none;
          width: 80px; height: 3px;
          background: rgba(255,255,255,0.2);
          border-radius: 99px; outline: none; cursor: pointer;
        }
        .vol-slider::-webkit-slider-thumb {
          -webkit-appearance: none; appearance: none;
          width: 12px; height: 12px;
          border-radius: 50%; background: #8B1A1A; cursor: pointer;
        }

        .ctrl-btn {
          background: none; border: none; cursor: pointer;
          color: rgba(255,255,255,0.7); padding: 0.35rem;
          border-radius: 50%; transition: color 0.15s, background 0.15s;
          display: flex; align-items: center; justify-content: center;
        }
        .ctrl-btn:hover { color: #fff; background: rgba(255,255,255,0.08); }
        .ctrl-btn.primary {
          width: 2.5rem; height: 2.5rem;
          background: #8B1A1A; color: #fff; border-radius: 50%;
        }
        .ctrl-btn.primary:hover { background: #a02020; }

        .cover-thumb {
          width: 2.75rem; height: 2.75rem; border-radius: 0.4rem;
          object-fit: cover; background: #3a1010;
          display: flex; align-items: center; justify-content: center;
          flex-shrink: 0;
        }

        .waveform-bars {
          display: flex; align-items: flex-end; gap: 2px; height: 20px;
        }
        .waveform-bars span {
          display: inline-block; width: 3px; background: #8B1A1A;
          border-radius: 2px; animation: wave 0.8s ease-in-out infinite alternate;
        }
        .waveform-bars span:nth-child(2) { animation-delay: 0.1s; }
        .waveform-bars span:nth-child(3) { animation-delay: 0.2s; }
        .waveform-bars span:nth-child(4) { animation-delay: 0.15s; }
        .waveform-bars span:nth-child(5) { animation-delay: 0.05s; }
        @keyframes wave {
          from { height: 4px; } to { height: 18px; }
        }

        .tag-badge {
          display: inline-block; padding: 0.15rem 0.5rem;
          font-size: 0.65rem; font-weight: 600; letter-spacing: 0.05em;
          text-transform: uppercase; border-radius: 99px;
          background: rgba(139,26,26,0.1); color: #8B1A1A;
        }

        /* hide the native audio element but keep it functional */
        #native-audio { display: none; }
      </style>

      <div class="audio-page" style="padding: 1.5rem 1.5rem 6rem; display: flex; flex-direction: column; gap: 1.5rem;">

        <%!-- ══ PAGE HEADER ══ --%>
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <div>
            <h1 style="font-size: 1.4rem; font-weight: 800; color: #1a0505;
                       font-family: 'Syne', sans-serif; margin-bottom: 0.15rem; letter-spacing: -0.02em;">
              Audio Manager
            </h1>
            <p style="font-size: 0.82rem; color: #9ca3af;">
              Upload, manage and play your audio tracks.
            </p>
          </div>

          <div style="display: flex; align-items: center; gap: 0.75rem;">
            <button
              phx-click="toggle-filter"
              style="display: inline-flex; align-items: center; gap: 0.4rem;
                     padding: 0.45rem 1rem; font-size: 0.82rem; font-weight: 500;
                     color: #374151; background: #fff; border: 1px solid #E8E2D9;
                     border-radius: 0.5rem; cursor: pointer;"
              onmouseover="this.style.background='#FAF8F5'"
              onmouseout="this.style.background='#fff'"
            >
              <.icon name="hero-funnel" class="size-4" /> Filter
            </button>

            <button
              phx-click="add_audio"
              style="display: inline-flex; align-items: center; gap: 0.4rem;
                     padding: 0.45rem 1rem; font-size: 0.82rem; font-weight: 500;
                     color: #fff; background: #8B1A1A; border: none;
                     border-radius: 0.5rem; cursor: pointer;"
              onmouseover="this.style.opacity='0.88'"
              onmouseout="this.style.opacity='1'"
            >
              <.icon name="hero-plus" class="size-4" /> Upload Track
            </button>
          </div>
        </div>

        <%!-- ══ FILTER PANEL ══ --%>
        <%= if @filter_expanded do %>
          <div style="background: #fff; border: 1px solid #E8E2D9;
                      border-top: 3px solid #8B1A1A; border-radius: 0.75rem; padding: 1.25rem;">
            <p style="font-size: 0.75rem; font-weight: 600; color: #374151;
                      text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 1rem;">
              Filters
            </p>
            <.form for={%{}} as={:filter} phx-change="filter">
              <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1rem;">
                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                  <label style="font-size: 0.75rem; font-weight: 500; color: #374151;">Search</label>
                  <.input name="filter[search_filter]" placeholder="Search tracks..." value={@search_filter} />
                </div>
                <div style="display: flex; flex-direction: column; gap: 0.35rem;">
                  <label style="font-size: 0.75rem; font-weight: 500; color: #374151;">Status</label>
                  <.input
                    type="select"
                    name="filter[status_filter]"
                    prompt="All"
                    options={[{"Active", "active"}, {"Inactive", "inactive"}]}
                    value={@status_filter}
                  />
                </div>
              </div>
            </.form>
          </div>
        <% end %>

        <%!-- ══ NOW PLAYING HERO (shown when a track is selected) ══ --%>
        <%= if @now_playing do %>
          <div style="background: linear-gradient(135deg, #1a0505 0%, #3a0a0a 60%, #5a1515 100%);
                      border-radius: 0.75rem; padding: 1.5rem; display: flex; align-items: center;
                      gap: 1.5rem; position: relative; overflow: hidden;">
            <%!-- decorative circle --%>
            <div style="position: absolute; right: -3rem; top: -3rem; width: 12rem; height: 12rem;
                        border-radius: 50%; background: rgba(139,26,26,0.25); pointer-events: none;"></div>
            <div style="position: absolute; right: 4rem; bottom: -4rem; width: 8rem; height: 8rem;
                        border-radius: 50%; background: rgba(139,26,26,0.15); pointer-events: none;"></div>

            <%!-- Cover art --%>
            <div style="width: 5rem; height: 5rem; border-radius: 0.75rem; flex-shrink: 0;
                        background: rgba(255,255,255,0.08); display: flex; align-items: center;
                        justify-content: center; border: 1px solid rgba(255,255,255,0.1);
                        overflow: hidden;">
              <%= if @now_playing.image_url do %>
                <img src={@now_playing.image_url} style="width: 100%; height: 100%; object-fit: cover;" />
              <% else %>
                <.icon name="hero-musical-note" style="width: 2rem; height: 2rem; color: rgba(255,255,255,0.4);" />
              <% end %>
            </div>

            <%!-- Info + waveform --%>
            <div style="flex: 1; min-width: 0;">
              <p style="font-size: 0.68rem; color: rgba(255,255,255,0.5); text-transform: uppercase;
                        letter-spacing: 0.1em; margin: 0 0 0.2rem; font-weight: 600;">Now Playing</p>
              <h3 style="font-size: 1.05rem; font-weight: 700; color: #fff; margin: 0 0 0.1rem;
                         font-family: 'Syne', sans-serif; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                {@now_playing.title}
              </h3>
              <p style="font-size: 0.8rem; color: rgba(255,255,255,0.6); margin: 0 0 0.75rem;">
                {@now_playing.artist}
                <%= if @now_playing.category do %>
                  <span style="margin-left: 0.5rem; padding: 0.1rem 0.45rem; background: rgba(139,26,26,0.5);
                                color: #ffb3b3; border-radius: 99px; font-size: 0.65rem; font-weight: 600;">
                    {@now_playing.category}
                  </span>
                <% end %>
              </p>
              <div class="waveform-bars">
                <span style="height: 8px;"></span>
                <span style="height: 14px;"></span>
                <span style="height: 18px;"></span>
                <span style="height: 10px;"></span>
                <span style="height: 16px;"></span>
                <span style="height: 6px;"></span>
                <span style="height: 12px;"></span>
                <span style="height: 18px;"></span>
                <span style="height: 8px;"></span>
                <span style="height: 14px;"></span>
              </div>
            </div>

            <%!-- Quick edit button --%>
            <button
              phx-click="edit"
              phx-value-id={@now_playing.id}
              style="padding: 0.4rem 0.9rem; font-size: 0.75rem; font-weight: 500;
                     color: rgba(255,255,255,0.7); background: rgba(255,255,255,0.08);
                     border: 1px solid rgba(255,255,255,0.15); border-radius: 0.4rem; cursor: pointer;
                     display: inline-flex; align-items: center; gap: 0.3rem; flex-shrink: 0;"
            >
              <.icon name="hero-pencil-square" style="width: 0.8rem; height: 0.8rem;" /> Edit
            </button>
          </div>
        <% end %>

        <%!-- ══ TRACK LIST ══ --%>
        <div style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; overflow: hidden;">

          <div style="padding: 1rem 1.25rem; border-bottom: 1px solid #E8E2D9;
                      display: flex; align-items: center; justify-content: space-between;">
            <div style="display: flex; align-items: center; gap: 0.5rem;">
              <div style="width: 0.2rem; height: 1rem; background: #8B1A1A; border-radius: 99px;"></div>
              <h2 style="font-size: 0.85rem; font-weight: 700; color: #1a0505; font-family: 'Syne', sans-serif;">
                All Tracks
              </h2>
              <span style="font-size: 0.72rem; color: #9ca3af; font-weight: 400;">
                ({length(@data)} tracks)
              </span>
            </div>
          </div>

          <%!-- Track rows --%>
          <div style="padding: 0.5rem 0;">
            <%= if @data == [] do %>
              <div style="padding: 3rem; text-align: center;">
                <div style="width: 3rem; height: 3rem; background: rgba(139,26,26,0.08); border-radius: 50%;
                            display: flex; align-items: center; justify-content: center; margin: 0 auto 0.75rem;">
                  <.icon name="hero-musical-note" style="width: 1.5rem; height: 1.5rem; color: #8B1A1A;" />
                </div>
                <p style="font-size: 0.85rem; color: #9ca3af; margin: 0;">No tracks yet. Upload your first track!</p>
              </div>
            <% end %>

            <%= for {audio, idx} <- Enum.with_index(@data, 1) do %>
              <div
                class={"track-row #{if @now_playing && @now_playing.id == audio.id, do: "playing", else: ""}"}
                style="display: grid; grid-template-columns: 2rem 2.5rem 1fr 1fr 6rem 5rem 5rem;
                       align-items: center; gap: 0.75rem; padding: 0.5rem 1.25rem;"
              >
                <%!-- Index / playing indicator --%>
                <div style="text-align: center;">
                  <%= if @now_playing && @now_playing.id == audio.id do %>
                    <div class="waveform-bars" style="justify-content: center;">
                      <span style="height: 6px;"></span>
                      <span style="height: 12px;"></span>
                      <span style="height: 8px;"></span>
                    </div>
                  <% else %>
                    <span style="font-size: 0.75rem; color: #9ca3af;">{idx}</span>
                  <% end %>
                </div>

                <%!-- Cover --%>
                <div style="width: 2.25rem; height: 2.25rem; border-radius: 0.35rem; overflow: hidden;
                            background: #f3eded; display: flex; align-items: center; justify-content: center;">
                  <%= if audio.image_url do %>
                    <img src={audio.image_url} style="width: 100%; height: 100%; object-fit: cover;" />
                  <% else %>
                    <.icon name="hero-musical-note" style="width: 1rem; height: 1rem; color: #8B1A1A;" />
                  <% end %>
                </div>

                <%!-- Title + Artist --%>
                <div style="min-width: 0;">
                  <p style={"font-size: 0.82rem; font-weight: 600; margin: 0; white-space: nowrap;
                             overflow: hidden; text-overflow: ellipsis;
                             color: #{if @now_playing && @now_playing.id == audio.id, do: "#8B1A1A", else: "#1a0505"};"}>
                    {audio.title}
                  </p>
                  <p style="font-size: 0.72rem; color: #9ca3af; margin: 0; white-space: nowrap;
                            overflow: hidden; text-overflow: ellipsis;">
                    {audio.artist}
                  </p>
                </div>

                <%!-- Description --%>
                <div style="min-width: 0;">
                  <p style="font-size: 0.75rem; color: #6b7280; margin: 0; white-space: nowrap;
                            overflow: hidden; text-overflow: ellipsis;">
                    {audio.description}
                  </p>
                </div>

                <%!-- Category badge --%>
                <div>
                  <%= if audio.category do %>
                    <span class="tag-badge">{audio.category}</span>
                  <% end %>
                </div>

                <%!-- Play button --%>
                  <div style="display: flex; justify-content: center;">
                    <button
                      phx-click="play"
                      phx-value-id={audio.id}
                      phx-hook="TrackPlay"
                      id={"play-btn-#{audio.id}"}
                      data-src={audio.file_url}
                      data-title={audio.title}
                      data-artist={audio.artist || ""}
                      data-cover={audio.image_url || ""}
                      style="display: inline-flex; align-items: center; gap: 0.3rem;
                            padding: 0.3rem 0.75rem; font-size: 0.72rem; font-weight: 600;
                            color: #8B1A1A; background: rgba(139,26,26,0.08);
                            border: none; border-radius: 99px; cursor: pointer;"
                      onmouseover="this.style.background='rgba(139,26,26,0.18)'"
                      onmouseout="this.style.background='rgba(139,26,26,0.08)'"
                    >
                      <.icon name="hero-play" style="width: 0.75rem; height: 0.75rem;" /> Play
                    </button>
                  </div>

                <%!-- Edit button --%>
                <div style="display: flex; justify-content: flex-end;">
                  <button
                    phx-click="edit"
                    phx-value-id={audio.id}
                    style="display: inline-flex; align-items: center; gap: 0.3rem;
                           padding: 0.25rem 0.65rem; font-size: 0.72rem; font-weight: 500;
                           color: #374151; background: #fff;
                           border: 1px solid #E8E2D9; border-radius: 0.4rem; cursor: pointer;"
                    onmouseover="this.style.borderColor='#8B1A1A'; this.style.color='#8B1A1A'"
                    onmouseout="this.style.borderColor='#E8E2D9'; this.style.color='#374151'"
                  >
                    <.icon name="hero-pencil-square" style="width: 0.75rem; height: 0.75rem;" /> Edit
                  </button>
                </div>
              </div>
            <% end %>
          </div>

          <%!-- Loading spinner --%>
          <%= if @data_loader do %>
            <div style="padding: 2.5rem; text-align: center;">
              <svg xmlns="http://www.w3.org/2000/svg"
                   style="width: 2rem; height: 2rem; color: #8B1A1A; animation: spin 1s linear infinite; margin: 0 auto;"
                   fill="none" viewBox="0 0 24 24">
                <circle style="opacity: 0.25;" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                <path style="opacity: 0.75;" fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962
                         7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
              </svg>
            </div>
          <% end %>

          <div style="border-top: 1px solid #E8E2D9;">
            <.live_component
              module={EnrouteHayeWeb.PaginationComponent}
              id="PaginationComponent"
              params={@params}
              pagination_data={@data_pagenations}
            />
          </div>

        </div>

      </div>

      <%!-- ══ PERSISTENT PLAYER BAR ══ --%>
      <audio id="native-audio" preload="none"></audio>

      <div class="player-bar" id="player-bar">
        <%!-- Track info --%>
        <div style="display: flex; align-items: center; gap: 0.75rem; width: 220px; flex-shrink: 0;">
          <div id="player-cover"
               style="width: 2.75rem; height: 2.75rem; border-radius: 0.4rem;
                      background: rgba(255,255,255,0.08); flex-shrink: 0;
                      display: flex; align-items: center; justify-content: center;
                      border: 1px solid rgba(255,255,255,0.08); overflow: hidden;">
            <.icon name="hero-musical-note" style="width: 1rem; height: 1rem; color: rgba(255,255,255,0.3);" />
          </div>
          <div style="min-width: 0;">
            <p id="player-title" style="font-size: 0.78rem; font-weight: 600; color: #fff;
                                        margin: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
              No track selected
            </p>
            <p id="player-artist" style="font-size: 0.68rem; color: rgba(255,255,255,0.5); margin: 0;
                                         white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
              —
            </p>
          </div>
        </div>

        <%!-- Controls + progress --%>
        <div style="flex: 1; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <div style="display: flex; align-items: center; gap: 0.75rem;">
            <%!-- Shuffle --%>
            <button class="ctrl-btn" id="btn-shuffle" onclick="toggleShuffle()" title="Shuffle">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" style="width:1rem;height:1rem;">
                <polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/>
                <polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/>
              </svg>
            </button>
            <%!-- Prev --%>
            <button class="ctrl-btn" onclick="prevTrack()" title="Previous">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                   style="width:1.1rem;height:1.1rem;">
                <path d="M6 6h2v12H6zm3.5 6 8.5 6V6z"/>
              </svg>
            </button>
            <%!-- Play/Pause --%>
            <button class="ctrl-btn primary" id="btn-play-pause" onclick="togglePlay()" title="Play / Pause">
              <svg id="icon-play" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                   style="width:1.1rem;height:1.1rem;">
                <path d="M8 5v14l11-7z"/>
              </svg>
              <svg id="icon-pause" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                   style="width:1.1rem;height:1.1rem;display:none;">
                <path d="M6 19h4V5H6v14zm8-14v14h4V5h-4z"/>
              </svg>
            </button>
            <%!-- Next --%>
            <button class="ctrl-btn" onclick="nextTrack()" title="Next">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                   style="width:1.1rem;height:1.1rem;">
                <path d="M6 18l8.5-6L6 6v12zm2-8.14 5.09 3.64L8 17.14V9.86zM16 6h2v12h-2z"/>
              </svg>
            </button>
            <%!-- Repeat --%>
            <button class="ctrl-btn" id="btn-repeat" onclick="toggleRepeat()" title="Repeat">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2" style="width:1rem;height:1rem;">
                <polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/>
                <polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/>
              </svg>
            </button>
          </div>

          <%!-- Progress --%>
          <div style="display: flex; align-items: center; gap: 0.6rem; width: 100%; max-width: 480px;">
            <span id="time-current" style="font-size: 0.65rem; color: rgba(255,255,255,0.45); width: 2.5rem; text-align: right;">0:00</span>
            <div class="progress-bar-wrap" id="progress-wrap" onclick="seekAudio(event)">
              <div class="progress-fill" id="progress-fill"></div>
            </div>
            <span id="time-total" style="font-size: 0.65rem; color: rgba(255,255,255,0.45); width: 2.5rem;">0:00</span>
          </div>
        </div>

        <%!-- Volume --%>
        <div style="display: flex; align-items: center; gap: 0.5rem; width: 160px; justify-content: flex-end; flex-shrink: 0;">
          <button class="ctrl-btn" onclick="toggleMute()" id="btn-mute" title="Mute">
            <svg id="icon-vol" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                 style="width:1rem;height:1rem;">
              <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z"/>
            </svg>
            <svg id="icon-mute" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor"
                 style="width:1rem;height:1rem;display:none;">
              <path d="M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3 3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4 9.91 6.09 12 8.18V4z"/>
            </svg>
          </button>
          <input type="range" class="vol-slider" id="vol-slider"
                 min="0" max="100" value="80"
                 oninput="setVolume(this.value)" />
        </div>
      </div>

      <%!-- ══ PLAYER JAVASCRIPT ══ --%>
      <script>
        const audio = document.getElementById('native-audio');
        let isRepeat = false;
        let isShuffle = false;

        function fmt(s) {
          if (isNaN(s)) return '0:00';
          const m = Math.floor(s / 60);
          const ss = String(Math.floor(s % 60)).padStart(2, '0');
          return `${m}:${ss}`;
        }

        audio.addEventListener('timeupdate', () => {
          const pct = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
          document.getElementById('progress-fill').style.width = pct + '%';
          document.getElementById('time-current').textContent = fmt(audio.currentTime);
          document.getElementById('time-total').textContent = fmt(audio.duration);
        });

        audio.addEventListener('play', () => {
          document.getElementById('icon-play').style.display = 'none';
          document.getElementById('icon-pause').style.display = 'block';
        });

        audio.addEventListener('pause', () => {
          document.getElementById('icon-play').style.display = 'block';
          document.getElementById('icon-pause').style.display = 'none';
        });

        audio.addEventListener('ended', () => {
          if (isRepeat) { audio.currentTime = 0; audio.play(); }
        });

        function togglePlay() {
          if (audio.paused) { audio.play(); } else { audio.pause(); }
        }

        function toggleMute() {
          audio.muted = !audio.muted;
          document.getElementById('icon-vol').style.display = audio.muted ? 'none' : 'block';
          document.getElementById('icon-mute').style.display = audio.muted ? 'block' : 'none';
        }

        function setVolume(val) {
          audio.volume = val / 100;
          if (audio.muted && val > 0) {
            audio.muted = false;
            document.getElementById('icon-vol').style.display = 'block';
            document.getElementById('icon-mute').style.display = 'none';
          }
        }

        function seekAudio(e) {
          const wrap = document.getElementById('progress-wrap');
          const rect = wrap.getBoundingClientRect();
          const pct = (e.clientX - rect.left) / rect.width;
          audio.currentTime = pct * audio.duration;
        }

        function toggleRepeat() {
          isRepeat = !isRepeat;
          const btn = document.getElementById('btn-repeat');
          btn.style.color = isRepeat ? '#8B1A1A' : '';
        }

        function toggleShuffle() {
          isShuffle = !isShuffle;
          const btn = document.getElementById('btn-shuffle');
          btn.style.color = isShuffle ? '#8B1A1A' : '';
        }

        function prevTrack() {
          if (audio.currentTime > 3) { audio.currentTime = 0; } else { audio.load(); }
        }

        function nextTrack() { audio.load(); }

        // Initial volume
        audio.volume = 0.8;
      </script>

      <%!-- ══ MODAL ══ --%>
      <%= if @live_action in [:new, :edit] do %>
        <.modal
          id={"crud-audio-modal-#{(@audio && @audio.id) || :new}"}
          show
          on_cancel={JS.push("close")}
        >
          <.live_component
            module={EnrouteHayeWeb.Audio.FormComponent}
            id={(@audio && @audio.id) || :new}
            title={@page_title}
            action={@live_action}
            audio={@audio}
            patch={~p"/admin/audio"}
          />
        </.modal>
      <% end %>

    </Layouts.admin_app>
    """
  end
end
