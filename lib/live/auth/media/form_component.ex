defmodule EnrouteHayeWeb.Media.FormComponent do
  use EnrouteHayeWeb, :live_component

  alias EnrouteHaye.Context.CxtMedia

  @impl true
  def mount(socket) do
    IO.inspect(socket.assigns, label: "======FormComponent mount assigns")

    socket =
      socket
      |> allow_upload(:video,
        accept: ~w(.mp4 .mov .webm),
        max_entries: 1,
        max_file_size: 100_000_000,
        auto_upload: true
      )
      |> allow_upload(:poster,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: 1,
        max_file_size: 10_000_000,
        auto_upload: true
      )

    IO.inspect(socket.assigns.uploads.video, label: "======[mount] video upload config registered")
    IO.inspect(socket.assigns.uploads.poster, label: "======[mount] poster upload config registered")

    {:ok, socket}
  end

  @impl true
  def update(%{media: media} = assigns, socket) do
    IO.inspect(socket.assigns, label: "======FormComponent update assigns")
    IO.inspect(media, label: "======[update] media struct received")

    changeset = CxtMedia.change_media(media)
    IO.inspect(changeset, label: "======[update] fresh changeset")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    # Fires on EVERY re-render — including every upload progress tick.
    # Cheap way to watch entries/progress/errors update live without
    # relying on handle_event, since LiveView handles upload progress
    # internally and never calls our handle_event clauses for it.
    IO.inspect(
      Enum.map(assigns.uploads.video.entries, fn e ->
        %{
          client_name: e.client_name,
          progress: e.progress,
          done?: e.done?,
          valid?: e.valid?,
          cancelled?: e.cancelled?,
          errors: upload_errors(assigns.uploads.video, e)
        }
      end),
      label: "======[render] video entries snapshot"
    )

    IO.inspect(
      Enum.map(assigns.uploads.poster.entries, fn e ->
        %{
          client_name: e.client_name,
          progress: e.progress,
          done?: e.done?,
          valid?: e.valid?,
          cancelled?: e.cancelled?,
          errors: upload_errors(assigns.uploads.poster, e)
        }
      end),
      label: "======[render] poster entries snapshot"
    )

    IO.inspect(upload_errors(assigns.uploads.video), label: "======[render] top-level video upload errors")
    IO.inspect(upload_errors(assigns.uploads.poster), label: "======[render] top-level poster upload errors")

    ~H"""
    <div style="background: #fff; border-radius: 0.75rem; width: 100%; box-sizing: border-box; font-family: 'Inter', sans-serif;">

      <%!-- ══ HEADER ══ --%>
      <div style="background: #8B1A1A; border-radius: 0.75rem 0.75rem 0 0;
                  padding: 1rem 1.5rem; display: flex; align-items: center; gap: 0.6rem;">
        <div style="width: 2rem; height: 2rem; background: rgba(255,255,255,0.15);
                    border-radius: 0.4rem; display: flex; align-items: center; justify-content: center;">
          <.icon name="hero-video-camera" style="width: 1rem; height: 1rem; color: #fff;" />
        </div>
        <div>
          <h2 style="font-size: 0.92rem; font-weight: 600; color: #fff; margin: 0;">{@title}</h2>
          <p style="font-size: 0.72rem; color: rgba(255,255,255,0.65); margin: 0;">
            Fill in the details below to {if @action == :new, do: "create a new media item", else: "update the media item"}.
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
        <%!-- ══ MAIN GRID: form left | upload right ══ --%>
        <div style="display: grid; grid-template-columns: 1fr 200px; gap: 1rem; align-items: start; width: 100%; box-sizing: border-box;">

          <%!-- LEFT COLUMN — form fields --%>
          <div style="display: flex; flex-direction: column; gap: 1.25rem;">

            <%!-- Section: Media Info --%>
            <div>
              <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                        text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                        display: flex; align-items: center; gap: 0.4rem;">
                <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
                Media Info
              </p>
              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                <.input field={@form[:title]} label="Title" />
                <.input field={@form[:author]} label="Author" />
              </div>
              <div style="margin-top: 0.75rem;">
                <.input
                  type="textarea"
                  field={@form[:description]}
                  label="Description"
                  style="min-height: 80px; resize: vertical;"
                />
              </div>
            </div>

            <%!-- Section: Details --%>
            <div>
              <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                        text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                        display: flex; align-items: center; gap: 0.4rem;">
                <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
                Details
              </p>
              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                <.input field={@form[:category]} label="Category" />
                <.input field={@form[:location]} label="Location" />
                <.input
                  type="select"
                  field={@form[:media_type]}
                  label="Media Type"
                  options={[
                    {"Video", "video"},
                    {"Documentary", "documentary"},
                    {"Interview", "interview"},
                    {"Podcast", "podcast"},
                    {"Other", "other"}
                  ]}
                  prompt="Select a type"
                />
                <.input type="number" field={@form[:minutes]} label="Duration (minutes)" min="0" />
              </div>
            </div>

          </div>

          <%!-- RIGHT COLUMN — upload panel --%>
          <div style="display: flex; flex-direction: column; gap: 0.75rem;">

            <%!-- ── Video upload ── --%>
            <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                      text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.1rem;
                      display: flex; align-items: center; gap: 0.4rem;">
              <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
              Media File
            </p>

            <div
              phx-drop-target={@uploads.video.ref}
              style="border: 2px dashed #E8E2D9; border-radius: 0.65rem;
                     background: #FAF8F5; padding: 1.25rem 0.75rem;
                     display: flex; flex-direction: column; align-items: center;
                     justify-content: center; gap: 0.5rem; text-align: center; min-height: 140px;
                     width: 100%; box-sizing: border-box; transition: border-color 0.15s;"
            >
              <div style="width: 2.5rem; height: 2.5rem; background: rgba(139,26,26,0.08);
                          border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                <.icon name="hero-video-camera" style="width: 1.25rem; height: 1.25rem; color: #8B1A1A;" />
              </div>
              <div>
                <p style="font-size: 0.75rem; font-weight: 500; color: #374151; margin: 0;">
                  Drop video here
                </p>
                <p style="font-size: 0.68rem; color: #9ca3af; margin: 0.1rem 0 0;">
                  MP4, MOV, WEBM · max 100 MB
                </p>
              </div>
              <label style="margin-top: 0.25rem; padding: 0.35rem 0.9rem; font-size: 0.75rem;
                            font-weight: 500; color: #8B1A1A; background: #fff;
                            border: 1px solid #8B1A1A; border-radius: 0.4rem; cursor: pointer;">
                Browse
                <.live_file_input upload={@uploads.video} style="display: none;" />
              </label>
            </div>

            <%= for entry <- @uploads.video.entries do %>
              <div style="border: 1px solid #E8E2D9; border-radius: 0.5rem;
                          padding: 0.5rem 0.65rem; background: #fff;
                          display: flex; align-items: center; gap: 0.5rem;">
                <.icon name="hero-film" style="width: 1.75rem; height: 1.75rem; color: #8B1A1A;" />
                <div style="flex: 1; min-width: 0;">
                  <p style="font-size: 0.7rem; font-weight: 500; color: #374151;
                            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin: 0;">
                    {entry.client_name}
                  </p>
                  <div style="margin-top: 0.2rem; height: 3px; background: #E8E2D9; border-radius: 99px; overflow: hidden;">
                    <div style={"width: #{entry.progress}%; height: 100%; background: #8B1A1A; transition: width 0.3s;"}></div>
                  </div>
                  <p style="font-size: 0.65rem; color: #16a34a; margin: 0.15rem 0 0;">
                    progress: {entry.progress}% · done?: {entry.done?}
                  </p>
                </div>
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  phx-value-upload="video"
                  phx-target={@myself}
                  style="color: #9ca3af; background: none; border: none; cursor: pointer; padding: 0;"
                >
                  <.icon name="hero-x-mark" style="width: 0.9rem; height: 0.9rem;" />
                </button>
              </div>

              <%= for err <- upload_errors(@uploads.video, entry) do %>
                <p style="font-size: 0.7rem; color: #dc2626; margin: 0;">{error_to_string(err)}</p>
              <% end %>
            <% end %>

            <%= for err <- upload_errors(@uploads.video) do %>
              <p style="font-size: 0.7rem; color: #dc2626; margin: 0;">{error_to_string(err)}</p>
            <% end %>

            <%!-- ── Poster upload ── --%>
            <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                      text-transform: uppercase; letter-spacing: 0.1em; margin: 0.75rem 0 0.1rem;
                      display: flex; align-items: center; gap: 0.4rem;">
              <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
              Poster Image
              <span style="font-weight: 400; text-transform: none; letter-spacing: 0; color: #9ca3af;">(optional)</span>
            </p>

            <div
              phx-drop-target={@uploads.poster.ref}
              style="border: 2px dashed #E8E2D9; border-radius: 0.65rem;
                     background: #FAF8F5; padding: 1rem 0.75rem;
                     display: flex; flex-direction: column; align-items: center;
                     justify-content: center; gap: 0.4rem; text-align: center; min-height: 110px;
                     width: 100%; box-sizing: border-box; transition: border-color 0.15s;"
            >
              <div style="width: 2rem; height: 2rem; background: rgba(139,26,26,0.08);
                          border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                <.icon name="hero-photo" style="width: 1rem; height: 1rem; color: #8B1A1A;" />
              </div>
              <p style="font-size: 0.72rem; font-weight: 500; color: #374151; margin: 0;">
                Drop poster here
              </p>
              <p style="font-size: 0.65rem; color: #9ca3af; margin: 0;">
                JPG, PNG, WEBP · max 10 MB
              </p>
              <label style="margin-top: 0.15rem; padding: 0.3rem 0.8rem; font-size: 0.7rem;
                            font-weight: 500; color: #8B1A1A; background: #fff;
                            border: 1px solid #8B1A1A; border-radius: 0.4rem; cursor: pointer;">
                Browse
                <.live_file_input upload={@uploads.poster} style="display: none;" />
              </label>
            </div>

            <%= for entry <- @uploads.poster.entries do %>
              <div style="border: 1px solid #E8E2D9; border-radius: 0.5rem;
                          padding: 0.5rem 0.65rem; background: #fff;
                          display: flex; align-items: center; gap: 0.5rem;">
                <.live_img_preview entry={entry} style="width: 2rem; height: 2rem; object-fit: cover; border-radius: 0.3rem;" />
                <div style="flex: 1; min-width: 0;">
                  <p style="font-size: 0.7rem; font-weight: 500; color: #374151;
                            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin: 0;">
                    {entry.client_name}
                  </p>
                  <div style="margin-top: 0.2rem; height: 3px; background: #E8E2D9; border-radius: 99px; overflow: hidden;">
                    <div style={"width: #{entry.progress}%; height: 100%; background: #8B1A1A; transition: width 0.3s;"}></div>
                  </div>
                  <p style="font-size: 0.65rem; color: #16a34a; margin: 0.15rem 0 0;">
                    progress: {entry.progress}% · done?: {entry.done?}
                  </p>
                </div>
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  phx-value-upload="poster"
                  phx-target={@myself}
                  style="color: #9ca3af; background: none; border: none; cursor: pointer; padding: 0;"
                >
                  <.icon name="hero-x-mark" style="width: 0.9rem; height: 0.9rem;" />
                </button>
              </div>

              <%= for err <- upload_errors(@uploads.poster, entry) do %>
                <p style="font-size: 0.7rem; color: #dc2626; margin: 0;">{error_to_string(err)}</p>
              <% end %>
            <% end %>

            <%= for err <- upload_errors(@uploads.poster) do %>
              <p style="font-size: 0.7rem; color: #dc2626; margin: 0;">{error_to_string(err)}</p>
            <% end %>
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
            disabled={upload_in_progress?(@uploads)}
            style="padding: 0.5rem 1.25rem; font-size: 0.82rem; border-radius: 0.5rem;
                   border: none; background: #8B1A1A; color: #fff; cursor: pointer;
                   display: inline-flex; align-items: center; gap: 0.35rem;"
          >
            <.icon name="hero-check" style="width: 0.85rem; height: 0.85rem;" />
            {if @action == :new, do: "Create Media", else: "Save Changes"}
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref, "upload" => "poster"}, socket) do
    IO.inspect(ref, label: "======[cancel-upload] poster ref cancelled")
    {:noreply, cancel_upload(socket, :poster, ref)}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    IO.inspect(ref, label: "======[cancel-upload] video ref cancelled")
    {:noreply, cancel_upload(socket, :video, ref)}
  end

  @impl true
  def handle_event("validate", %{"media" => params}, socket) do
    IO.inspect(params, label: "======[validate] raw form params")

    changeset =
      socket.assigns.media
      |> CxtMedia.change_media(params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset.valid?, label: "======[validate] changeset valid?")
    IO.inspect(changeset.errors, label: "======[validate] changeset errors")

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"media" => params}, socket) do
    IO.inspect(params, label: "======[save] raw form params BEFORE consume")

    IO.inspect(
      Enum.map(socket.assigns.uploads.video.entries, & &1.client_name),
      label: "======[save] video entries about to be consumed"
    )

    IO.inspect(
      Enum.map(socket.assigns.uploads.poster.entries, & &1.client_name),
      label: "======[save] poster entries about to be consumed"
    )

    video_paths =
      consume_uploaded_entries(socket, :video, fn meta, entry ->
        IO.inspect(meta, label: "======[consume:video] tmp file meta from LiveView")
        result = copy_entry(meta, entry, "uploads")
        IO.inspect(result, label: "======[consume:video] copy_entry result")
        result
      end)

    poster_paths =
      consume_uploaded_entries(socket, :poster, fn meta, entry ->
        IO.inspect(meta, label: "======[consume:poster] tmp file meta from LiveView")
        result = copy_entry(meta, entry, "posters")
        IO.inspect(result, label: "======[consume:poster] copy_entry result")
        result
      end)

    IO.inspect(video_paths, label: "======[save] full video consume result list")
    IO.inspect(poster_paths, label: "======[save] full poster consume result list")

    file_path = List.first(video_paths)
    poster_path = List.first(poster_paths)
    IO.inspect(file_path, label: "======[save] chosen file_path (List.first)")
    IO.inspect(poster_path, label: "======[save] chosen poster_path (List.first)")

    params =
      params
      |> maybe_put("file_path", file_path)
      |> maybe_put("poster_path", poster_path)

    IO.inspect(params, label: "======[save] params AFTER merging file_path/poster_path")

    case socket.assigns.action do
      :new -> create_media(socket, params)
      :edit -> update_media(socket, params)
    end
  end

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Map.put(params, key, value)

  defp upload_in_progress?(uploads) do
    result =
      Enum.any?(uploads.video.entries, &(!&1.done?)) or
        Enum.any?(uploads.poster.entries, &(!&1.done?))

    IO.inspect(result, label: "======[upload_in_progress?] disables submit button?")
    result
  end

  defp copy_entry(%{path: path}, entry, subdir) do
    IO.inspect(File.exists?(path), label: "======[copy_entry:#{subdir}] tmp path exists?")

    dest_dir = Path.join([:code.priv_dir(:enroute_haye), "static", subdir])
    File.mkdir_p!(dest_dir)

    safe_name =
      entry.client_name
      |> Path.basename()
      |> String.replace(~r/[^a-zA-Z0-9._-]/, "_")

    filename = "#{System.unique_integer([:positive])}_#{safe_name}"
    dest = Path.join(dest_dir, filename)

    IO.inspect(dest, label: "======[copy_entry:#{subdir}] destination path")

    File.cp!(path, dest)

    IO.inspect(File.exists?(dest), label: "======[copy_entry:#{subdir}] file copied successfully?")

    {:ok, "/#{subdir}/#{filename}"}
  end

  defp create_media(socket, params) do
    IO.inspect(params, label: "======[create_media] final params sent to context")

    case CxtMedia.create_media(params) do
      {:ok, media} ->
        IO.inspect(media, label: "======[create_media] SUCCESS — persisted record")
        notify_parent({:saved, media})

        {:noreply,
         socket
         |> put_flash(:info, "Media created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "======[create_media] FAILURE — changeset errors")
        IO.inspect(changeset.changes, label: "======[create_media] FAILURE — changeset changes")

        {:noreply,
         socket
         |> put_flash(:error, "Couldn't save media — please check the highlighted fields.")
         |> assign(form: to_form(changeset))}
    end
  end

  defp update_media(socket, params) do
    IO.inspect(params, label: "======[update_media] final params sent to context")

    case CxtMedia.update_media(socket.assigns.media, params) do
      {:ok, media} ->
        IO.inspect(media, label: "======[update_media] SUCCESS — persisted record")
        notify_parent({:saved, media})

        {:noreply,
         socket
         |> put_flash(:info, "Media updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "======[update_media] FAILURE — changeset errors")
        IO.inspect(changeset.changes, label: "======[update_media] FAILURE — changeset changes")

        {:noreply,
         socket
         |> put_flash(:error, "Couldn't save media — please check the highlighted fields.")
         |> assign(form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp error_to_string(:too_large), do: "File too large"
  defp error_to_string(:not_accepted), do: "Unsupported file type"
  defp error_to_string(:too_many_files), do: "Only 1 file allowed"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
