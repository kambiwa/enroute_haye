defmodule EnrouteHayeWeb.UserLive.Login do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Accounts

    @impl true
  def render(assigns) do
    ~H"""
    <Layouts.unauth_app flash={@flash} current_scope={@current_scope}>

      <%!-- ══════════════════════════════════════════════════════
           Page wrapper — light landing-page background
      ═══════════════════════════════════════════════════════════ --%>
      <div class="kuomboka-bg min-h-[calc(100vh-64px)] flex items-center justify-center px-6 py-10">

        <%!-- ══════════════════════════════════════════════════════
             Floating card
        ═══════════════════════════════════════════════════════════ --%>
        <div class="bg-white rounded-[1.75rem] overflow-hidden flex w-full max-w-[820px] min-h-[520px] shadow-2xl">

          <%!-- ══════════════════════════════════════════
               LEFT — form panel
          ══════════════════════════════════════════ --%>
          <div class="flex-1 px-11 py-12 flex flex-col justify-center bg-white">

            <%!-- Wordmark --%>
            <div class="flex items-center gap-2 mb-3">
              <span class="w-2 h-2 rounded-full bg-zm-copper inline-block"></span>
              <span class="font-zm-display text-sm font-bold text-zm-ink tracking-wide">Discover Zambia</span>
            </div>

            <%!-- Heading --%>
            <h1 class="font-zm-display text-3xl font-bold text-zm-ink leading-tight mb-7">
              Sign in to your<br/>
              <span class="text-zm-copper">Heritage</span> journey
            </h1>

            <%!-- Divider --%>
            <div class="flex items-center gap-2.5 mb-4">
              <span class="flex-1 h-px bg-zm-soft-gray"></span>
              <span class="text-[0.62rem] tracking-[0.18em] uppercase text-zm-body/60">Enroute Home</span>
              <span class="flex-1 h-px bg-zm-soft-gray"></span>
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
              <div class="mb-3">
                <input
                  id={f[:email].id}
                  name={f[:email].name}
                  type="email"
                  value={f[:email].value}
                  readonly={!!@current_scope}
                  autocomplete="username"
                  spellcheck="false"
                  required
                  placeholder={if @current_scope, do: f[:email].value, else: "Email address"}
                  phx-mounted={JS.focus()}
                  class="w-full px-4 py-3 text-sm border-[1.5px] border-zm-soft-gray rounded-lg
                         outline-none bg-zm-soft-gray/20 text-zm-ink transition-colors
                         focus:border-zm-copper focus:bg-white focus:ring-4 focus:ring-zm-copper/10"
                />
              </div>

              <%!-- Password --%>
              <div class="mb-2">
                <input
                  id={f[:password].id}
                  name={f[:password].name}
                  type="password"
                  autocomplete="current-password"
                  spellcheck="false"
                  required
                  placeholder="Password"
                  class="w-full px-4 py-3 text-sm border-[1.5px] border-zm-soft-gray rounded-lg
                         outline-none bg-zm-soft-gray/20 text-zm-ink transition-colors
                         focus:border-zm-copper focus:bg-white focus:ring-4 focus:ring-zm-copper/10"
                />
              </div>

              <%!-- Forgot password --%>
              <div class="text-right mb-6">
                <a href="#" class="text-xs text-zm-copper hover:underline">
                  Forgot password?
                </a>
              </div>

              <%!-- Primary CTA --%>
              <button
                type="submit"
                name={f[:remember_me].name}
                value="true"
                class="zm-btn-primary w-full flex items-center justify-center gap-2 text-sm mb-2.5"
              >
                Sign in
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                </svg>
              </button>
            </.form>

            <%!-- Footer link --%>
            <div class="mt-6 text-center text-sm text-zm-body/70">
              <%= if @current_scope do %>
                Reauthenticate to continue with sensitive actions.
              <% else %>
                Don't have an account?
                <.link navigate={~p"/users/register"} class="text-zm-terracotta font-semibold hover:underline">
                  Create one →
                </.link>
              <% end %>
            </div>

          </div>

          <%!-- ══════════════════════════════════════════
               RIGHT — Victoria Falls image panel
               Hidden on mobile, shown on lg+
          ══════════════════════════════════════════ --%>
          <div class="hidden lg:block relative w-[46%] flex-shrink-0 m-4 ml-0 rounded-2xl overflow-hidden bg-zm-ink">

            <%!-- Hero image --%>
            <img
              src={~p"/images/sites/victoria_falls.jpg"}
              alt="Victoria Falls, Zambia"
              class="absolute inset-0 w-full h-full object-cover opacity-80"
            />

            <%!-- Subtle grid overlay --%>
            <div class="absolute inset-0 opacity-10"
                 style="background-image:
                   repeating-linear-gradient(90deg, rgba(255,255,255,.5) 0, rgba(255,255,255,.5) 1px, transparent 1px, transparent 44px),
                   repeating-linear-gradient(0deg, rgba(255,255,255,.5) 0, rgba(255,255,255,.5) 1px, transparent 1px, transparent 44px);">
            </div>

            <%!-- Bottom fade for text legibility --%>
            <div class="absolute inset-0 bg-gradient-to-t from-zm-ink/90 to-transparent to-55%"></div>

            <%!-- Copper radial glow accent --%>
            <div class="absolute top-[15%] right-[10%] w-40 h-40 rounded-full pointer-events-none"
                 style="background: radial-gradient(circle, rgba(201,109,58,0.25) 0%, transparent 70%);">
            </div>

            <%!-- UNESCO badge — top left --%>
            <div class="absolute top-5 left-5 bg-zm-ink/70 backdrop-blur-md border border-zm-copper/35 rounded-xl px-3.5 py-2">
              <div class="text-zm-copper text-[0.58rem] font-bold tracking-[0.18em] uppercase mb-0.5">
                UNESCO Wonder
              </div>
              <div class="text-white text-sm font-bold">Victoria Falls</div>
              <div class="text-white/50 text-xs">Livingstone, Zambia</div>
            </div>

            <%!-- Bottom text overlay --%>
            <div class="absolute bottom-0 left-0 right-0 px-7 pt-6 pb-8">

              <div class="flex items-center gap-1.5 text-zm-copper text-[0.6rem] font-bold tracking-[0.22em] uppercase mb-2">
                <svg class="w-1.5 h-1.5 flex-shrink-0" viewBox="0 0 7 7" fill="currentColor">
                  <polygon points="3.5,0 4.3,2.6 7,2.6 4.8,4.2 5.6,6.8 3.5,5.2 1.4,6.8 2.2,4.2 0,2.6 2.7,2.6"/>
                </svg>
                Welcome to Zambia
              </div>

              <h2 class="font-zm-display text-white text-xl font-bold leading-tight mb-2.5">
                Discover.<br/>
                <span class="text-zm-copper">Live Our Heritage.</span>
              </h2>

              <%!-- Copper rule --%>
              <div class="flex items-center gap-2">
                <span class="block w-8 h-0.5 bg-zm-copper rounded-full"></span>
                <span class="w-1.5 h-1.5 rounded-full bg-zm-terracotta block"></span>
                <span class="block w-7 h-px bg-white/20"></span>
              </div>

            </div>
          </div>

        </div>
      </div>

    </Layouts.unauth_app>
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
