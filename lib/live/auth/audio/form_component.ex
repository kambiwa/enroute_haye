defmodule EnrouteHayeWeb.Audio.FormComponent do
  use EnrouteHayeWeb, :live_component

  alias EnrouteHaye.Context.CxtAudio

  @impl true
  def update(%{audio: audio} = assigns, socket) do
    changeset = CxtAudio.change_audio(audio)

    {:ok,
     socket
     |> assign(assigns)
     |> allow_upload(:image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 5_000_000
     )
     |> allow_upload(:audio_file,
       accept: ~w(.mp3 .wav),
       max_entries: 1,
       max_file_size: 50_000_000
     )
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style="background: #fff; border-radius: 0.75rem; width: 100%; box-sizing: border-box; font-family: 'DM Sans', sans-serif;">

      <%!-- ══ HEADER ══ --%>
      <div style="background: #8B1A1A; border-radius: 0.75rem 0.75rem 0 0;
                  padding: 1rem 1.5rem; display: flex; align-items: center; gap: 0.6rem;">
        <div style="width: 2rem; height: 2rem; background: rgba(255,255,255,0.15);
                    border-radius: 0.4rem; display: flex; align-items: center; justify-content: center;">
          <.icon name="hero-musical-note" style="width: 1rem; height: 1rem; color: #fff;" />
        </div>
        <div>
          <h2 style="font-size: 0.92rem; font-weight: 600; color: #fff; margin: 0;">{@title}</h2>
          <p style="font-size: 0.72rem; color: rgba(255,255,255,0.65); margin: 0;">
            Fill in the details below to {if @action == :new, do: "upload a new track", else: "update the track"}.
          </p>
        </div>
      </div>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        style="padding: 1.25rem; width: 100%; box-sizing: border-box; overflow: hidden;"
      >
        <%!-- ══ MAIN GRID: fields left | uploads right ══ --%>
        <div style="display: grid; grid-template-columns: 1fr 180px; gap: 1rem; align-items: start; width: 100%; box-sizing: border-box;">

          <%!-- LEFT — form fields --%>
          <div style="display: flex; flex-direction: column; gap: 1.25rem;">

            <%!-- Section: Track Info --%>
            <div>
              <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                        text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                        display: flex; align-items: center; gap: 0.4rem;">
                <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
                Track Info
              </p>
              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                <.input field={@form[:title]} label="Title" placeholder="e.g. Midnight Hymn" />
                <.input field={@form[:artist]} label="Artist" placeholder="e.g. John Doe" />
                <.input field={@form[:category]} label="Genre / Category" placeholder="e.g. Gospel" />
                <.input field={@form[:file_url]} label="File URL (or upload below)" placeholder="https://..." />
              </div>
              <div style="margin-top: 0.75rem;">
                <.input
                  type="textarea"
                  field={@form[:description]}
                  label="Description"
                  placeholder="A short description of the track..."
                  style="min-height: 72px; resize: vertical;"
                />
              </div>
            </div>

          </div>

          <%!-- RIGHT — upload panels --%>
          <div style="display: flex; flex-direction: column; gap: 1rem;">

            <%!-- Cover image upload --%>
            <div>
              <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                        text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.5rem;
                        display: flex; align-items: center; gap: 0.4rem;">
                <span style="display: inline-block; width: 1.5rem; height: 1px; background: #8B1A1A;"></span>
                Cover
              </p>
              <div
                phx-drop-target={@uploads.image.ref}
                style="border: 2px dashed #E8E2D9; border-radius: 0.65rem;
                       background: #FAF8F5; padding: 1rem 0.75rem;
                       display: flex; flex-direction: column; align-items: center;
                       justify-content: center; gap: 0.4rem; text-align: center;
                       min-height: 110px; width: 100%; box-sizing: border-box;"
              >
                <div style="width: 2rem; height: 2rem; background: rgba(139,26,26,0.08);
                            border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                  <.icon name="hero-photo" style="width: 1rem; height: 1rem; color: #8B1A1A;" />
                </div>
                <p style="font-size: 0.68rem; color: #9ca3af; margin: 0;">JPG, PNG, WEBP</p>
                <label style="padding: 0.3rem 0.75rem; font-size: 0.72rem; font-weight: 500;
                              color: #8B1A1A; background: #fff; border: 1px solid #8B1A1A;
                              border-radius: 0.35rem; cursor: pointer; margin-top: 0.1rem;">
                  Browse
                  <.live_file_input upload={@uploads.image} style="display: none;" />
                </label>
              </div>

              <%= for entry <- @uploads.image.entries do %>
                <div style="margin-top: 0.4rem; border: 1px solid #E8E2D9; border-radius: 0.4rem;
                            padding: 0.4rem 0.6rem; background: #fff; display: flex; align-items: center; gap: 0.4rem;">
                  <.live_img_preview entry={entry} style="width: 2rem; height: 2rem; object-fit: cover; border-radius: 0.25rem;" />
                  <div style="flex: 1; min-width: 0;">
                    <p style="font-size: 0.65rem; color: #374151; margin: 0;
                              white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{entry.client_name}</p>
                    <div style="height: 3px; background: #E8E2D9; border-radius: 99px; margin-top: 0.15rem; overflow: hidden;">
                      <div style={"width: #{entry.progress}%; height: 100%; background: #8B1A1A;"}></div>
                    </div>
                  </div>
                  <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}
                          phx-target={@myself} style="color: #9ca3af; background: none; border: none; cursor: pointer; padding: 0;">
                    <.icon name="hero-x-mark" style="width: 0.8rem; height: 0.8rem;" />
                  </button>
                </div>
                <%= for err <- upload_errors(@uploads.image, entry) do %>
                  <p style="font-size: 0.65rem; color: #dc2626; margin: 0.2rem 0 0;">{error_to_string(err)}</p>
                <% end %>
              <% end %>
            </div>

            <%!-- Audio file upload --%>
            <div>
              <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                        text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.5rem;
                        display: flex; align-items: center; gap: 0.4rem;">
                <span style="display: inline-block; width: 1.5rem; height: 1px; background: #8B1A1A;"></span>
                Audio File
              </p>
              <div
                phx-drop-target={@uploads.audio_file.ref}
                style="border: 2px dashed #E8E2D9; border-radius: 0.65rem;
                       background: #FAF8F5; padding: 1rem 0.75rem;
                       display: flex; flex-direction: column; align-items: center;
                       justify-content: center; gap: 0.4rem; text-align: center;
                       min-height: 110px; width: 100%; box-sizing: border-box;"
              >
                <div style="width: 2rem; height: 2rem; background: rgba(139,26,26,0.08);
                            border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                  <.icon name="hero-musical-note" style="width: 1rem; height: 1rem; color: #8B1A1A;" />
                </div>
                <p style="font-size: 0.68rem; color: #9ca3af; margin: 0;">MP3, WAV, OGG, M4A</p>
                <label style="padding: 0.3rem 0.75rem; font-size: 0.72rem; font-weight: 500;
                              color: #8B1A1A; background: #fff; border: 1px solid #8B1A1A;
                              border-radius: 0.35rem; cursor: pointer; margin-top: 0.1rem;">
                  Browse
                  <.live_file_input upload={@uploads.audio_file} style="display: none;" />
                </label>
              </div>

              <%= for entry <- @uploads.audio_file.entries do %>
                <div style="margin-top: 0.4rem; border: 1px solid #E8E2D9; border-radius: 0.4rem;
                            padding: 0.4rem 0.6rem; background: #fff; display: flex; align-items: center; gap: 0.4rem;">
                  <div style="width: 2rem; height: 2rem; background: rgba(139,26,26,0.08); border-radius: 0.25rem;
                              display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <.icon name="hero-musical-note" style="width: 0.9rem; height: 0.9rem; color: #8B1A1A;" />
                  </div>
                  <div style="flex: 1; min-width: 0;">
                    <p style="font-size: 0.65rem; color: #374151; margin: 0;
                              white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">{entry.client_name}</p>
                    <div style="height: 3px; background: #E8E2D9; border-radius: 99px; margin-top: 0.15rem; overflow: hidden;">
                      <div style={"width: #{entry.progress}%; height: 100%; background: #8B1A1A;"}></div>
                    </div>
                  </div>
                  <button type="button" phx-click="cancel-audio-upload" phx-value-ref={entry.ref}
                          phx-target={@myself} style="color: #9ca3af; background: none; border: none; cursor: pointer; padding: 0;">
                    <.icon name="hero-x-mark" style="width: 0.8rem; height: 0.8rem;" />
                  </button>
                </div>
                <%= for err <- upload_errors(@uploads.audio_file, entry) do %>
                  <p style="font-size: 0.65rem; color: #dc2626; margin: 0.2rem 0 0;">{error_to_string(err)}</p>
                <% end %>
              <% end %>
            </div>

          </div>
        </div>

        <%!-- ══ ACTIONS ══ --%>
        <div style="margin-top: 1.5rem; padding-top: 1rem; border-top: 1px solid #E8E2D9;
                    display: flex; justify-content: flex-end; gap: 0.5rem;">
          <button
            type="button"
            phx-click="close"
            phx-target={@myself}
            style="padding: 0.5rem 1.1rem; font-size: 0.82rem; border-radius: 0.5rem;
                   border: 1px solid #E8E2D9; background: #fff; cursor: pointer; color: #374151;"
          >
            Cancel
          </button>
          <button
            type="submit"
            style="padding: 0.5rem 1.25rem; font-size: 0.82rem; border-radius: 0.5rem;
                   border: none; background: #8B1A1A; color: #fff; cursor: pointer;
                   display: inline-flex; align-items: center; gap: 0.35rem;"
          >
            <.icon name="hero-check" style="width: 0.85rem; height: 0.85rem;" />
            {if @action == :new, do: "Upload Track", else: "Save Changes"}
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @impl true
  def handle_event("cancel-audio-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :audio_file, ref)}
  end

  @impl true
  def handle_event("validate", %{"audio" => params}, socket) do
    changeset =
      socket.assigns.audio
      |> CxtAudio.change_audio(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"audio" => params}, socket) do
    # Consume cover image
    image_url =
      consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
        dest = Path.join([:code.priv_dir(:enroute_haye), "static", "uploads", entry.client_name])
        File.cp!(path, dest)
        {:ok, "/uploads/#{entry.client_name}"}
      end)
      |> List.first()

    # Consume audio file — overrides file_url if a file was uploaded
    audio_file_url =
      consume_uploaded_entries(socket, :audio_file, fn %{path: path}, entry ->
        dest = Path.join([:code.priv_dir(:enroute_haye), "static", "uploads", entry.client_name])
        File.cp!(path, dest)
        {:ok, "/uploads/#{entry.client_name}"}
      end)
      |> List.first()

    params =
      params
      |> then(fn p -> if image_url, do: Map.put(p, "image_url", image_url), else: p end)
      |> then(fn p -> if audio_file_url, do: Map.put(p, "file_url", audio_file_url), else: p end)

    case socket.assigns.action do
      :new -> create_audio(socket, params)
      :edit -> update_audio(socket, params)
    end
  end

  defp create_audio(socket, params) do
    case CxtAudio.create_audio(params) do
      {:ok, audio} ->
        notify_parent({:saved, audio})

        {:noreply,
         socket
         |> put_flash(:info, "Track uploaded successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_audio(socket, params) do
    case CxtAudio.update_audio(socket.assigns.audio, params) do
      {:ok, audio} ->
        notify_parent({:saved, audio})

        {:noreply,
         socket
         |> put_flash(:info, "Track updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp error_to_string(:too_large), do: "File too large"
  defp error_to_string(:not_accepted), do: "Unsupported file type"
  defp error_to_string(:too_many_files), do: "Only 1 file allowed"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
