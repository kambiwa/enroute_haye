defmodule EnrouteHayeWeb.UserLive.Confirmation do
  use EnrouteHayeWeb, :live_view
  alias EnrouteHaye.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.unauth_app flash={@flash} current_scope={@current_scope}>
      <main class="mx-auto max-w-sm px-6 py-16">
        <h1 class="mb-6 text-2xl font-semibold">Welcome {@user.email}</h1>
        <.form
          :if={is_nil(@user.confirmed_at)}
          for={@form}
          id="confirmation_form"
          action={~p"/users/log-in?_action=confirmed"}
          phx-submit="submit"
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.button name={@form[:remember_me].name} value="true">Confirm and stay logged in</.button>
          <.button>Confirm my account</.button>
        </.form>
        <.form
          :if={@user.confirmed_at}
          for={@form}
          id="login_form"
          action={~p"/users/log-in"}
          phx-submit="submit"
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.button name={@form[:remember_me].name} value="true">
            Keep me logged in on this device
          </.button>
          <.button>Log in</.button>
        </.form>
      </main>
    </Layouts.unauth_app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    case Accounts.get_user_by_magic_link_token(token) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Magic link is invalid or it has expired.")
         |> push_navigate(to: ~p"/users/log-in")}

      user ->
        {:ok,
         assign(socket,
           user: user,
           form: to_form(%{"token" => token}, as: :user),
           trigger_submit: false
         ), temporary_assigns: [form: nil]}
    end
  end

  @impl true
  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: :user), trigger_submit: true)}
  end
end
