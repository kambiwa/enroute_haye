defmodule EnrouteHayeWeb.UserLive.Registration do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Accounts
  alias EnrouteHaye.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.unauth_app flash={@flash} current_scope={@current_scope}>

      <%!-- ══════════════════════════════════════════════════════
           Page wrapper — light landing-page background
      ═══════════════════════════════════════════════════════════ --%>
      <div class="kuomboka-bg min-h-[calc(100vh-72px)] flex items-center justify-center px-6 py-10">

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
            <h1 class="font-zm-display text-3xl font-bold text-zm-ink leading-tight mb-2">
              Create your<br/>
              <span class="text-zm-copper">Heritage</span> account
            </h1>

            <%!-- Divider --%>
            <div class="flex items-center gap-2.5 mb-4">
              <span class="flex-1 h-px bg-zm-soft-gray"></span>
              <span class="text-[0.62rem] tracking-[0.18em] uppercase text-zm-body/60">Enroute Home</span>
              <span class="flex-1 h-px bg-zm-soft-gray"></span>
            </div>

            <%!-- Form --%>
            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
            >

              <%!-- Email --%>
              <div class="mb-3">
                <input
                  id={@form[:email].id}
                  name={@form[:email].name}
                  type="email"
                  value={@form[:email].value}
                  autocomplete="username"
                  spellcheck="false"
                  required
                  placeholder="Email address"
                  phx-mounted={JS.focus()}
                  phx-debounce="300"
                  class="w-full px-4 py-3 text-sm border-[1.5px] border-zm-soft-gray rounded-lg
                         outline-none bg-zm-soft-gray/20 text-zm-ink transition-colors
                         focus:border-zm-copper focus:bg-white focus:ring-4 focus:ring-zm-copper/10"
                />
                <%= if msg = @form[:email].errors |> List.first() do %>
                  <p class="text-zm-terracotta text-xs mt-1.5">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
              </div>

              <%!-- Password --%>
              <div class="mb-1.5">
                <input
                  id={@form[:password].id}
                  name={@form[:password].name}
                  type="password"
                  value={@form[:password].value}
                  autocomplete="new-password"
                  required
                  placeholder="Password"
                  phx-debounce="300"
                  class="w-full px-4 py-3 text-sm border-[1.5px] border-zm-soft-gray rounded-lg
                         outline-none bg-zm-soft-gray/20 text-zm-ink transition-colors
                         focus:border-zm-copper focus:bg-white focus:ring-4 focus:ring-zm-copper/10"
                />
                <%= if msg = @form[:password].errors |> List.first() do %>
                  <p class="text-zm-terracotta text-xs mt-1.5">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
              </div>

              <%!-- Password hint --%>
              <p class="text-xs text-zm-body/60 mb-6">
                Minimum 12 characters.
              </p>
              <p class="text-sm text-zm-body/80 mb-7 leading-relaxed">
                Already have an account?
                <.link navigate={~p"/users/log-in"} class="text-zm-terracotta font-semibold hover:underline">
                  Sign in →
                </.link>
              </p>

              <%!-- Submit --%>
              <button
                type="submit"
                phx-disable-with="Creating account..."
                class="zm-btn-primary w-full flex items-center justify-center gap-2 text-sm"
              >
                Create account
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                </svg>
              </button>

            </.form>

            <%!-- Back to home --%>
            <div class="mt-6 text-center text-sm text-zm-body/60">
              <.link navigate={~p"/"} class="text-zm-body/70 hover:underline">
                ← Back to Discover Zambia
              </.link>
            </div>

          </div>

          <%!-- ══════════════════════════════════════════
               RIGHT — heritage image panel
               Hidden on mobile, shown on lg+
          ══════════════════════════════════════════ --%>
          <div class="hidden lg:block relative w-[46%] flex-shrink-0 m-4 mr-4 ml-0 rounded-2xl overflow-hidden bg-zm-ink">

            <%!-- Hero image --%>
            <img
              src={~p"/images/Kuomboka_2022-5.jpg"}
              alt="Nalikwanda royal barge — Kuomboka ceremony"
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
            <div class="absolute top-[15%] left-[10%] w-40 h-40 rounded-full pointer-events-none"
                 style="background: radial-gradient(circle, rgba(201,109,58,0.25) 0%, transparent 70%);">
            </div>

            <%!-- Heritage badge — top left --%>
            <div class="absolute top-5 left-5 bg-zm-ink/70 backdrop-blur-md border border-zm-copper/35 rounded-xl px-3.5 py-2">
              <div class="text-zm-copper text-[0.58rem] font-bold tracking-[0.18em] uppercase mb-0.5">
                Living Heritage
              </div>
              <div class="text-white text-sm font-bold">Kuomboka Ceremony</div>
              <div class="text-white/50 text-xs">Western Province, Zambia</div>
            </div>

            <%!-- Bottom text overlay --%>
            <div class="absolute bottom-0 left-0 right-0 px-7 pt-6 pb-8">

              <div class="flex items-center gap-1.5 text-zm-copper text-[0.6rem] font-bold tracking-[0.22em] uppercase mb-2">
                <svg class="w-1.5 h-1.5 flex-shrink-0" viewBox="0 0 7 7" fill="currentColor">
                  <polygon points="3.5,0 4.3,2.6 7,2.6 4.8,4.2 5.6,6.8 3.5,5.2 1.4,6.8 2.2,4.2 0,2.6 2.7,2.6"/>
                </svg>
                Begin your journey
              </div>

              <h2 class="font-zm-display text-white text-xl font-bold leading-tight mb-2.5">
                Join the living<br/>
                <span class="text-zm-copper">heritage of Zambia.</span>
              </h2>

              <p class="text-white/50 text-xs leading-relaxed max-w-[240px] mb-3">
                Become part of a community dedicated to preserving Africa's greatest ceremonies.
              </p>

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
