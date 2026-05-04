defmodule EnrouteHayeWeb.UserLive.Registration do
  use EnrouteHayeWeb, :live_view

  alias EnrouteHaye.Accounts
  alias EnrouteHaye.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.unauth_app flash={@flash} current_scope={@current_scope}>

      <%!-- ══════════════════════════════════════════════════════
           Page wrapper — dark forest green background
      ═══════════════════════════════════════════════════════════ --%>
      <div style="
        min-height: calc(100vh - 72px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 2.5rem 1.5rem;
        background: radial-gradient(ellipse at 70% 40%, rgba(28,43,26,0.9) 0%, #0f1a0e 70%);
        background-color: #0f1a0e;
      ">

        <%!-- ══════════════════════════════════════════════════════
             Floating white card
        ═══════════════════════════════════════════════════════════ --%>
        <div style="
          background: #ffffff;
          border-radius: 1.75rem;
          overflow: hidden;
          display: flex;
          width: 100%;
          max-width: 820px;
          min-height: 520px;
          box-shadow: 0 40px 100px rgba(0,0,0,0.45);
        ">

          <%!-- ══════════════════════════════════════════
               LEFT — form panel
          ══════════════════════════════════════════ --%>
          <div style="
            flex: 1;
            padding: 3rem 2.75rem;
            display: flex;
            flex-direction: column;
            justify-content: center;
            background: #ffffff;
          ">

            <%!-- Wordmark --%>
            <div style="
              display: flex;
              align-items: center;
              gap: 0.4rem;
              margin-bottom: 0.75rem;
            ">
              <span style="
                width: 7px; height: 7px;
                border-radius: 50%;
                background: #C9A84C;
                display: inline-block;
              "></span>
              <span style="
                font-family: Georgia, 'Times New Roman', serif;
                font-size: 0.95rem;
                font-weight: 700;
                color: #3B6D11;
                letter-spacing: 0.04em;
              ">Discover Zambia</span>
            </div>

            <%!-- Heading --%>
            <h1 style="
              font-family: Georgia, 'Times New Roman', serif;
              font-size: 1.85rem;
              font-weight: 700;
              color: #111;
              line-height: 1.2;
              margin-bottom: 0.5rem;
            ">
              Create your<br/>
              <span style="color: #C9A84C;">Heritage</span> account
            </h1>



            <%!-- Social buttons --%>
            <div style="display: flex; gap: 0.65rem; margin-bottom: 1.25rem;">
              <button type="button" style="
                flex: 1;
                display: flex; align-items: center; justify-content: center; gap: 0.4rem;
                padding: 0.6rem;
                border-radius: 0.6rem;
                border: 1.5px solid #e5e7eb;
                background: #fff;
                font-size: 0.75rem; font-weight: 600; color: #444;
                cursor: pointer;
                transition: border-color 0.2s, background 0.2s;"
                onmouseover="this.style.borderColor='#C9A84C'; this.style.background='#fefdf7';"
                onmouseout="this.style.borderColor='#e5e7eb'; this.style.background='#fff';">
                <svg style="width: 14px; height: 14px;" viewBox="0 0 24 24">
                  <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                  <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                  <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
                  <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                </svg>
                Sign up with Google
              </button>
              <button type="button" style="
                flex: 1;
                display: flex; align-items: center; justify-content: center; gap: 0.4rem;
                padding: 0.6rem;
                border-radius: 0.6rem;
                border: 1.5px solid #e5e7eb;
                background: #fff;
                font-size: 0.75rem; font-weight: 600; color: #444;
                cursor: pointer;
                transition: border-color 0.2s, background 0.2s;"
                onmouseover="this.style.borderColor='#C9A84C'; this.style.background='#fefdf7';"
                onmouseout="this.style.borderColor='#e5e7eb'; this.style.background='#fff';">
                <svg style="width: 14px; height: 14px;" viewBox="0 0 24 24" fill="#111">
                  <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z"/>
                </svg>
                Sign up with Apple
              </button>
            </div>

            <%!-- Divider --%>
            <div style="display: flex; align-items: center; gap: 0.6rem; margin-bottom: 1.1rem;">
              <span style="flex: 1; height: 1px; background: #e5e7eb;"></span>
              <span style="font-size: 0.62rem; letter-spacing: 0.18em; text-transform: uppercase; color: #9ca3af;">or</span>
              <span style="flex: 1; height: 1px; background: #e5e7eb;"></span>
            </div>

            <%!-- Form --%>
            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
            >

              <%!-- Email --%>
              <div style="margin-bottom: 0.8rem;">
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
                  style="
                    width: 100%; padding: 0.75rem 1rem; font-size: 0.875rem;
                    border: 1.5px solid #e5e7eb; border-radius: 0.6rem;
                    outline: none; background: #fafafa; color: #111;
                    transition: border-color 0.2s, box-shadow 0.2s;
                    box-sizing: border-box;"
                  onfocus="this.style.borderColor='#C9A84C'; this.style.boxShadow='0 0 0 3px rgba(201,168,76,0.12)'; this.style.background='#fff';"
                  onblur="this.style.borderColor='#e5e7eb'; this.style.boxShadow='none'; this.style.background='#fafafa';"
                />
                <%= if msg = @form[:email].errors |> List.first() do %>
                  <p style="color: #B45309; font-size: 0.72rem; margin-top: 0.35rem;">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
              </div>

              <%!-- Password --%>
              <div style="margin-bottom: 0.35rem;">
                <input
                  id={@form[:password].id}
                  name={@form[:password].name}
                  type="password"
                  value={@form[:password].value}
                  autocomplete="new-password"
                  required
                  placeholder="Password"
                  phx-debounce="300"
                  style="
                    width: 100%; padding: 0.75rem 1rem; font-size: 0.875rem;
                    border: 1.5px solid #e5e7eb; border-radius: 0.6rem;
                    outline: none; background: #fafafa; color: #111;
                    transition: border-color 0.2s, box-shadow 0.2s;
                    box-sizing: border-box;"
                  onfocus="this.style.borderColor='#C9A84C'; this.style.boxShadow='0 0 0 3px rgba(201,168,76,0.12)'; this.style.background='#fff';"
                  onblur="this.style.borderColor='#e5e7eb'; this.style.boxShadow='none'; this.style.background='#fafafa';"
                />
                <%= if msg = @form[:password].errors |> List.first() do %>
                  <p style="color: #B45309; font-size: 0.72rem; margin-top: 0.35rem;">
                    <%= translate_error(msg) %>
                  </p>
                <% end %>
              </div>

              <%!-- Password hint --%>
              <p style="font-size: 0.72rem; color: #9ca3af; margin-bottom: 1.5rem;">
                Minimum 12 characters.
              </p>
               <p style="font-size: 0.82rem; color: #6b7280; margin-bottom: 1.75rem; line-height: 1.6;">
              Already have an account?
              <.link
                navigate={~p"/users/log-in"}
                style="color: #3B6D11; font-weight: 600;"
                class="hover:underline"
              >
                Sign in →
              </.link>
            </p>

              <%!-- Submit --%>
              <button
                type="submit"
                phx-disable-with="Creating account..."
                style="
                  width: 100%;
                  display: flex; align-items: center; justify-content: center; gap: 0.5rem;
                  padding: 0.82rem 1.5rem;
                  border-radius: 0.6rem;
                  background: linear-gradient(110deg,#C9A84C 0%,#E8B94A 45%,#fff3c0 55%,#E8B94A 65%,#C9A84C 100%);
                  background-size: 200% auto;
                  color: #1a1a00; font-weight: 700; font-size: 0.875rem;
                  border: none; cursor: pointer;
                  letter-spacing: 0.02em;
                  transition: background-position 0.6s, box-shadow 0.3s;"
                onmouseover="this.style.backgroundPosition='right center'; this.style.boxShadow='0 6px 20px rgba(201,168,76,0.35)';"
                onmouseout="this.style.backgroundPosition='left center'; this.style.boxShadow='none';"
              >
                Create account
                <svg style="width: 1rem; height: 1rem;" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M17 8l4 4m0 0l-4 4m4-4H3"/>
                </svg>
              </button>

            </.form>

            <%!-- Back to home --%>
            <div style="margin-top: 1.5rem; text-align: center; font-size: 0.8rem; color: #9ca3af;">
              <.link navigate={~p"/"} style="color: #6b7280;" class="hover:underline">
                ← Back to Discover Zambia
              </.link>
            </div>

          </div>

          <%!-- ══════════════════════════════════════════
               RIGHT — heritage image panel
               Hidden on mobile, shown on lg+
          ══════════════════════════════════════════ --%>
          <div
            class="hidden lg:block"
            style="
              width: 46%;
              flex-shrink: 0;
              position: relative;
              margin: 1rem 1rem 1rem 0;
              border-radius: 1.25rem;
              overflow: hidden;
              background: #1C2B1A;
            ">

            <%!-- Hero image --%>
            <img
              src={~p"/images/Kuomboka_2022-5.jpg"}
              alt="Nalikwanda royal barge — Kuomboka ceremony"
              style="
                position: absolute; inset: 0;
                width: 100%; height: 100%;
                object-fit: cover;
                opacity: 0.72;"
            />

            <%!-- Subtle grid overlay --%>
            <div style="
              position: absolute; inset: 0; opacity: 0.12;
              background-image:
                repeating-linear-gradient(90deg, rgba(255,255,255,.07) 0, rgba(255,255,255,.07) 1px, transparent 1px, transparent 44px),
                repeating-linear-gradient(0deg, rgba(255,255,255,.07) 0, rgba(255,255,255,.07) 1px, transparent 1px, transparent 44px);
            "></div>

            <%!-- Bottom fade for text legibility --%>
            <div style="
              position: absolute; inset: 0;
              background: linear-gradient(to top, rgba(15,26,14,0.90) 0%, transparent 55%);
            "></div>

            <%!-- Gold radial glow accent --%>
            <div style="
              position: absolute; top: 15%; left: 10%;
              width: 160px; height: 160px;
              border-radius: 50%;
              background: radial-gradient(circle, rgba(201,168,76,0.18) 0%, transparent 70%);
              pointer-events: none;
            "></div>

            <%!-- Heritage badge — top left --%>
            <div style="
              position: absolute; top: 1.25rem; left: 1.25rem;
              background: rgba(15,26,14,0.72);
              backdrop-filter: blur(10px);
              border: 1px solid rgba(201,168,76,0.35);
              border-radius: 0.75rem;
              padding: 0.5rem 0.9rem;
            ">
              <div style="color: #E8B94A; font-size: 0.58rem; font-weight: 700; letter-spacing: 0.18em; text-transform: uppercase; margin-bottom: 0.15rem;">
                Living Heritage
              </div>
              <div style="color: white; font-size: 0.82rem; font-weight: 700;">Kuomboka Ceremony</div>
              <div style="color: rgba(255,255,255,0.5); font-size: 0.65rem;">Western Province, Zambia</div>
            </div>

            <%!-- Bottom text overlay --%>
            <div style="position: absolute; bottom: 0; left: 0; right: 0; padding: 1.5rem 1.75rem 2rem;">

              <div style="
                display: flex; align-items: center; gap: 0.4rem;
                color: #E8B94A; font-size: 0.6rem; font-weight: 700;
                letter-spacing: 0.22em; text-transform: uppercase;
                margin-bottom: 0.45rem;">
                <svg style="width: 7px; height: 7px; flex-shrink: 0;" viewBox="0 0 7 7" fill="#E8B94A">
                  <polygon points="3.5,0 4.3,2.6 7,2.6 4.8,4.2 5.6,6.8 3.5,5.2 1.4,6.8 2.2,4.2 0,2.6 2.7,2.6"/>
                </svg>
                Begin your journey
              </div>

              <h2 style="
                font-family: Georgia, 'Times New Roman', serif;
                color: white;
                font-size: 1.35rem; font-weight: 700; line-height: 1.2;
                margin-bottom: 0.6rem;">
                Join the living<br/>
                <span style="color: #E8B94A;">heritage of Zambia.</span>
              </h2>

              <p style="color: rgba(255,255,255,0.45); font-size: 0.78rem; line-height: 1.7; max-width: 240px; margin-bottom: 0.85rem;">
                Become part of a community dedicated to preserving Africa's greatest ceremonies.
              </p>

              <%!-- Gold rule --%>
              <div style="display: flex; align-items: center; gap: 0.5rem;">
                <span style="display: block; width: 32px; height: 2px; background: #C9A84C; border-radius: 1px;"></span>
                <span style="width: 5px; height: 5px; border-radius: 50%; background: #E8B94A; display: block;"></span>
                <span style="display: block; width: 28px; height: 1px; background: rgba(255,255,255,0.18);"></span>
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
