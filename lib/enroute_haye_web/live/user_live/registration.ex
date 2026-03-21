defmodule EnrouteHayeWeb.UserLive.Registration do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Accounts
  alias EnrouteHaye.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.unauth_no_footer flash={@flash} current_scope={@current_scope}>

      <%!-- Full viewport split below the 72px navbar --%>
      <div class="flex" style="min-height: calc(100vh - 72px);">

        <%!-- ══════════════════════════════════════════
             LEFT — image panel
        ══════════════════════════════════════════ --%>
        <div class="hidden lg:flex relative w-1/2 overflow-hidden flex-col"
             style="background: var(--black);">

          <img
            src="/images/Kuomboka_2022-5.jpg"
            alt="Nalikwanda royal barge"
            class="absolute inset-0 w-full h-full object-cover"
            style="opacity: 0.55;"
          />

          <%!-- Red diagonal accent --%>
          <div class="absolute inset-0 pointer-events-none"
               style="background: linear-gradient(135deg, rgba(204,0,0,0.5) 0%, transparent 55%);">
          </div>

          <%!-- Bottom fade for text legibility --%>
          <div class="absolute inset-0 pointer-events-none"
               style="background: linear-gradient(to top, rgba(0,0,0,0.75) 0%, transparent 55%);">
          </div>

          <%!-- Bottom text overlay --%>
          <div class="relative z-10 mt-auto p-10 pb-14">
            <p style="color: var(--red); font-size: 0.7rem; letter-spacing: 0.3em;
                      text-transform: uppercase; font-weight: 600; margin-bottom: 0.75rem;">
              Begin your journey
            </p>
            <h2 style="font-family: var(--font-display); color: var(--white);
                       font-size: 2.5rem; font-weight: 700; line-height: 1.15;
                       margin-bottom: 1.25rem;">
              Join the living<br/>heritage of Kuomboka
            </h2>
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
              <span style="display: block; width: 48px; height: 2px; background: var(--red);"></span>
              <span style="color: var(--red); font-size: 1rem;">〰</span>
              <span style="display: block; width: 48px; height: 2px;
                           background: rgba(255,255,255,0.2);"></span>
            </div>
            <p style="color: rgba(255,255,255,0.55); font-size: 0.88rem;
                      line-height: 1.8; max-width: 320px;">
              Create your account and become part of a community dedicated to
              preserving one of Africa's greatest ceremonies.
            </p>
          </div>

        </div>

        <%!-- ══════════════════════════════════════════
             RIGHT — form panel
        ══════════════════════════════════════════ --%>
        <div class="flex-1 flex items-center justify-center px-6 py-16"
             style="background: var(--white);">

          <div class="w-full" style="max-width: 400px;">

            <%!-- Heading --%>
            <div style="margin-bottom: 2.5rem;">
              <p style="color: var(--red); font-size: 0.7rem; letter-spacing: 0.28em;
                        text-transform: uppercase; font-weight: 600; margin-bottom: 0.6rem;">
                Get started
              </p>
              <h1 style="font-family: var(--font-display); font-size: 2rem;
                         font-weight: 700; color: var(--black); margin-bottom: 0.6rem;">
                Create an account
              </h1>
              <p style="font-size: 0.88rem; color: var(--gray-500);">
                Already have an account?
                <.link
                  navigate={~p"/users/log-in"}
                  style="color: var(--red); font-weight: 600;"
                  class="hover:underline"
                >
                  Sign in →
                </.link>
              </p>
            </div>

            <%!-- Form --%>
            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
            >

              <%!-- Email --%>
              <div style="margin-bottom: 1.25rem;">
                <label style="display: block; font-size: 0.68rem; letter-spacing: 0.12em;
                              text-transform: uppercase; color: var(--gray-400);
                              margin-bottom: 0.5rem;">
                  Email address
                </label>
                <input
                  id={@form[:email].id}
                  name={@form[:email].name}
                  type="email"
                  value={@form[:email].value}
                  autocomplete="username"
                  spellcheck="false"
                  required
                  phx-mounted={JS.focus()}
                  phx-debounce="300"
                  style="width: 100%; padding: 0.75rem 1rem; font-size: 0.88rem;
                         border: 1.5px solid var(--gray-200); outline: none;
                         background: var(--white); color: var(--black);
                         font-family: var(--font-body); transition: border-color 0.2s;"
                  onfocus="this.style.borderColor='var(--red)'"
                  onblur="this.style.borderColor='var(--gray-200)'"
                />
                <%= if msg = @form[:email].errors |> List.first() do %>
                  <p style="color: var(--red); font-size: 0.72rem; margin-top: 0.4rem;">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
              </div>

              <%!-- Password --%>
              <div style="margin-bottom: 2rem;">
                <label style="display: block; font-size: 0.68rem; letter-spacing: 0.12em;
                              text-transform: uppercase; color: var(--gray-400);
                              margin-bottom: 0.5rem;">
                  Password
                </label>
                <input
                  id={@form[:password].id}
                  name={@form[:password].name}
                  type="password"
                  value={@form[:password].value}
                  autocomplete="new-password"
                  required
                  phx-debounce="300"
                  style="width: 100%; padding: 0.75rem 1rem; font-size: 0.88rem;
                         border: 1.5px solid var(--gray-200); outline: none;
                         background: var(--white); color: var(--black);
                         font-family: var(--font-body); transition: border-color 0.2s;"
                  onfocus="this.style.borderColor='var(--red)'"
                  onblur="this.style.borderColor='var(--gray-200)'"
                />
                <%= if msg = @form[:password].errors |> List.first() do %>
                  <p style="color: var(--red); font-size: 0.72rem; margin-top: 0.4rem;">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
                <p style="font-size: 0.72rem; color: var(--gray-400); margin-top: 0.5rem;">
                  Minimum 12 characters.
                </p>
              </div>

              <%!-- Submit --%>
              <button
                type="submit"
                phx-disable-with="Creating account..."
                class="btn-primary"
                style="width: 100%; justify-content: center;"
                onmouseover="this.style.background='var(--red-deep)'"
                onmouseout="this.style.background='var(--red)'"
              >
                Create account →
              </button>

            </.form>

            <%!-- Divider --%>
            <div style="display: flex; align-items: center; gap: 0.75rem; margin: 1.75rem 0;">
              <span style="flex: 1; height: 1px; background: var(--gray-200);"></span>
              <span style="font-size: 0.68rem; letter-spacing: 0.2em;
                           text-transform: uppercase; color: var(--gray-400);">or</span>
              <span style="flex: 1; height: 1px; background: var(--gray-200);"></span>
            </div>

            <%!-- Back to home --%>
            <p style="text-align: center; font-size: 0.85rem;">
              <.link navigate={~p"/"} class="hover:underline"
                     style="color: var(--gray-500); transition: color 0.2s;">
                ← Back to Kuomboka
              </.link>
            </p>

          </div>
        </div>

      </div>

    </Layouts.unauth_no_footer>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: EnrouteHayeWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{}, %{})
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Account created successfully!")
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset, as: "user"))
  end
end
