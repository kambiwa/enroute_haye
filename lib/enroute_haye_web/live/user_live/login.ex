defmodule EnrouteHayeWeb.UserLive.Login do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Accounts

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
            src="/images/Kuomboka_PBentley-20.jpg"
            alt="Kuomboka ceremony — flood plains"
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
              The Litunga's Royal Voyage
            </p>
            <h2 style="font-family: var(--font-display); color: var(--white);
                       font-size: 2.5rem; font-weight: 700; line-height: 1.15;
                       margin-bottom: 1.25rem;">
              Welcome back<br/>to the journey
            </h2>
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 1.25rem;">
              <span style="display: block; width: 48px; height: 2px; background: var(--red);"></span>
              <span style="color: var(--red); font-size: 1rem;">〰</span>
              <span style="display: block; width: 48px; height: 2px;
                           background: rgba(255,255,255,0.2);"></span>
            </div>
            <p style="color: rgba(255,255,255,0.55); font-size: 0.88rem;
                      line-height: 1.8; max-width: 320px;">
              One of Africa's most spectacular living traditions — preserved and shared
              for generations to come.
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
                Welcome back
              </p>
              <h1 style="font-family: var(--font-display); font-size: 2rem;
                         font-weight: 700; color: var(--black); margin-bottom: 0.6rem;">
                Sign in
              </h1>
              <p style="font-size: 0.88rem; color: var(--gray-500);">
                <%= if @current_scope do %>
                  Reauthenticate to continue with sensitive actions.
                <% else %>
                  Don't have an account?
                  <.link
                    navigate={~p"/users/register"}
                    style="color: var(--red); font-weight: 600;"
                    class="hover:underline"
                  >
                    Create one →
                  </.link>
                <% end %>
              </p>
            </div>

            <%!-- Form --%>
            <.form
              :let={f}
              for={@form}
              id="login_form_password"
              action={~p"/users/log-in"}
              phx-submit="submit_password"
              phx-trigger-action={@trigger_submit}
            >

              <%!-- Email --%>
              <div style="margin-bottom: 1.25rem;">
                <label style="display: block; font-size: 0.68rem; letter-spacing: 0.12em;
                              text-transform: uppercase; color: var(--gray-400);
                              margin-bottom: 0.5rem;">
                  Email address
                </label>
                <input
                  id={f[:email].id}
                  name={f[:email].name}
                  type="email"
                  value={f[:email].value}
                  readonly={!!@current_scope}
                  autocomplete="username"
                  spellcheck="false"
                  required
                  phx-mounted={JS.focus()}
                  style="width: 100%; padding: 0.75rem 1rem; font-size: 0.88rem;
                         border: 1.5px solid var(--gray-200); outline: none;
                         background: var(--white); color: var(--black);
                         font-family: var(--font-body); transition: border-color 0.2s;"
                  onfocus="this.style.borderColor='var(--red)'"
                  onblur="this.style.borderColor='var(--gray-200)'"
                />
              </div>

              <%!-- Password --%>
              <div style="margin-bottom: 2rem;">
                <label style="display: block; font-size: 0.68rem; letter-spacing: 0.12em;
                              text-transform: uppercase; color: var(--gray-400);
                              margin-bottom: 0.5rem;">
                  Password
                </label>
                <input
                  id={f[:password].id}
                  name={f[:password].name}
                  type="password"
                  autocomplete="current-password"
                  spellcheck="false"
                  required
                  style="width: 100%; padding: 0.75rem 1rem; font-size: 0.88rem;
                         border: 1.5px solid var(--gray-200); outline: none;
                         background: var(--white); color: var(--black);
                         font-family: var(--font-body); transition: border-color 0.2s;"
                  onfocus="this.style.borderColor='var(--red)'"
                  onblur="this.style.borderColor='var(--gray-200)'"
                />
              </div>

              <%!-- Primary: stay logged in --%>
              <button
                type="submit"
                name={f[:remember_me].name}
                value="true"
                class="btn-primary"
                style="width: 100%; justify-content: center; margin-bottom: 0.75rem;"
                onmouseover="this.style.background='var(--red-deep)'"
                onmouseout="this.style.background='var(--red)'"
              >
                Log in and stay logged in →
              </button>

              <%!-- Secondary: one time --%>
              <button
                type="submit"
                class="btn-outline-red"
                style="width: 100%; justify-content: center;"
              >
                Log in only this time
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
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end
end
