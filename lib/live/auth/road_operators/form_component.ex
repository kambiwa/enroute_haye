defmodule EnrouteHayeWeb.Road.FormComponent do
  use EnrouteHayeWeb, :live_component

  alias EnrouteHaye.Context.CxtRoad

  @impl true
  def update(%{road: road} = assigns, socket) do
    changeset = CxtRoad.change_road_operator(road)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style="background: #fff; border-radius: 0.75rem; width: 100%; box-sizing: border-box; font-family: 'Inter', sans-serif;">

      <%!-- ══ HEADER ══ --%>
      <div style="background: #8B1A1A; border-radius: 0.75rem 0.75rem 0 0;
                  padding: 1rem 1.5rem; display: flex; align-items: center; gap: 0.6rem;">
        <div style="width: 2rem; height: 2rem; background: rgba(255,255,255,0.15);
                    border-radius: 0.4rem; display: flex; align-items: center; justify-content: center;">
          <.icon name="hero-truck" style="width: 1rem; height: 1rem; color: #fff;" />
        </div>
        <div>
          <h2 style="font-size: 0.92rem; font-weight: 600; color: #fff; margin: 0;">{@title}</h2>
          <p style="font-size: 0.72rem; color: rgba(255,255,255,0.65); margin: 0;">
            {if @action == :new,
              do: "Add a new road operator and route.",
              else: "Update road operator details."}
          </p>
        </div>
      </div>

      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        style="padding: 1.25rem; width: 100%; box-sizing: border-box;"
      >
        <div style="display: flex; flex-direction: column; gap: 1.5rem;">

          <%!-- ── SECTION: Operator Info ── --%>
          <div>
            <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                      text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                      display: flex; align-items: center; gap: 0.4rem;">
              <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
              Operator Info
            </p>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
              <.input
                field={@form[:operator]}
                label="Operator Name"
                placeholder="e.g. Mazhandu Family Bus"
              />
              <.input
                field={@form[:operator_contact]}
                label="Contact"
                placeholder="e.g. +260 97 123 4567"
              />
            </div>
          </div>

          <%!-- ── SECTION: Route ── --%>
          <div>
            <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                      text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                      display: flex; align-items: center; gap: 0.4rem;">
              <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
              Route
            </p>
            <div style="display: flex; flex-direction: column; gap: 0.75rem;">
              <.input
                field={@form[:route]}
                label="Route Name"
                placeholder="e.g. Lusaka – Mongu"
              />
              <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem;">
                <.input
                  field={@form[:departure_point]}
                  label="Departure Point"
                  placeholder="e.g. Lusaka City Market"
                />
                <.input
                  field={@form[:arrival_point]}
                  label="Arrival Point"
                  placeholder="e.g. Mongu Bus Station"
                />
              </div>
            </div>
          </div>

          <%!-- ── SECTION: Schedule & Pricing ── --%>
          <div>
            <p style="font-size: 0.7rem; font-weight: 700; color: #8B1A1A;
                      text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 0.75rem;
                      display: flex; align-items: center; gap: 0.4rem;">
              <span style="display: inline-block; width: 2rem; height: 1px; background: #8B1A1A;"></span>
              Schedule & Pricing
            </p>
            <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 0.75rem;">
              <.input
                field={@form[:departure_time]}
                label="Departure Time"
                type="datetime-local"
              />
              <.input
                field={@form[:arrival_time]}
                label="Arrival Time"
                type="datetime-local"
              />
              <.input
                field={@form[:price]}
                label="Price (USD)"
                type="number"
                step="0.01"
                placeholder="e.g. 45.00"
              />
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
            {if @action == :new, do: "Create Operator", else: "Save Changes"}
          </button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"road" => params}, socket) do
    changeset =
      socket.assigns.road
      |> CxtRoad.change_road_operator(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"road" => params}, socket) do
    case socket.assigns.action do
      :new  -> create_road(socket, params)
      :edit -> update_road(socket, params)
    end
  end

  @impl true
  def handle_event("close", _params, socket) do
    send(self(), {__MODULE__, :close})
    {:noreply, socket}
  end

  defp create_road(socket, params) do
    case CxtRoad.create_road_operator(params) do
      {:ok, road} ->
        notify_parent({:saved, road})

        {:noreply,
         socket
         |> put_flash(:info, "Road operator created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_road(socket, params) do
    case CxtRoad.update_road_operator(socket.assigns.road, params) do
      {:ok, road} ->
        notify_parent({:saved, road})

        {:noreply,
         socket
         |> put_flash(:info, "Road operator updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
