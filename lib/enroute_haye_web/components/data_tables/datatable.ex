defmodule EnrouteHayeWeb.Datatable.Table do

  use Phoenix.Component

  import EnrouteHayeWeb.CoreComponents, only: [icon: 1]

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  attr :actions_variant, :string, default: "menu", values: ~w(menu inline)
  attr :actions_label, :string, default: "Options"
  attr :empty_message, :string, default: "No records found"

  slot :col, required: true do
    attr :label, :string
    attr :icon, :string
    attr :cell_icon, :boolean
    attr :align, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      assigns
      |> assign(:has_actions?, not Enum.empty?(assigns.action))
      |> assign(:indexed_rows, Enum.with_index(assigns.rows))

    ~H"""
    <div id={"#{@id}-container"} class="dt-wrap">
      <style>
        .dt-wrap{background:#fff;border:1px solid #E8E2D9;border-radius:.9rem;overflow:hidden;
          box-shadow:0 1px 2px rgba(26,10,10,.04),0 10px 28px -14px rgba(139,26,26,.22)}
        .dt-scroll{overflow-x:auto}
        .dt-table{width:100%;border-collapse:separate;border-spacing:0;font-size:.83rem}

        /* ── Header ── */
        .dt-head th{position:relative;padding:.9rem 1.25rem;text-align:left;font-size:.68rem;
          font-weight:700;color:#fff;text-transform:uppercase;letter-spacing:.09em;white-space:nowrap;
          background:linear-gradient(135deg,#A32424 0%,#8B1A1A 45%,#661111 100%)}
        .dt-head tr{box-shadow:0 2px 0 rgba(0,0,0,.04)}
        .dt-head th:not(:last-child)::after{content:"";position:absolute;right:0;top:30%;
          height:40%;width:1px;background:rgba(255,255,255,.16)}
        .dt-th{display:inline-flex;align-items:center;gap:.55rem}
        .dt-th-icon{display:inline-flex;align-items:center;justify-content:center;width:1.55rem;
          height:1.55rem;border-radius:.45rem;background:rgba(255,255,255,.14);
          box-shadow:inset 0 0 0 1px rgba(255,255,255,.2)}

        /* ── Rows ── */
        .dt-row{animation:dt-rise .45s cubic-bezier(.2,.7,.2,1) both}
        .dt-row td{padding:.85rem 1.25rem;white-space:nowrap;color:#4b5563;
          border-top:1px solid #F1ECE5;transition:background .2s ease,box-shadow .2s ease}
        .dt-row:first-child td{border-top:none}
        .dt-row:nth-child(even) td{background:#FDFBF8}
        .dt-row:hover td{background:#FBF1EE}
        .dt-row:hover td:first-child{box-shadow:inset 3px 0 0 #8B1A1A}
        .dt-row--clickable td{cursor:pointer}

        .dt-cell{display:flex;align-items:center;gap:.65rem}
        .dt-cell-icon{display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;
          width:2rem;height:2rem;border-radius:.6rem;color:#8B1A1A;
          background:linear-gradient(135deg,rgba(139,26,26,.14),rgba(139,26,26,.04));
          box-shadow:inset 0 0 0 1px rgba(139,26,26,.1);
          transition:transform .3s cubic-bezier(.3,1.6,.5,1),background .2s}
        .dt-row:hover .dt-cell-icon{transform:scale(1.12) rotate(-6deg);
          background:#8B1A1A;color:#fff}

        @keyframes dt-rise{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}

        /* ── Options menu ── */
        .dt-kebab{display:inline-flex;align-items:center;justify-content:center;width:2rem;
          height:2rem;border-radius:999px;border:1px solid #E8E2D9;background:#fff;color:#6b7280;
          cursor:pointer;transition:all .25s cubic-bezier(.3,1.4,.5,1)}
        .dt-kebab:hover,.dt-kebab[aria-expanded="true"]{background:#8B1A1A;border-color:#8B1A1A;
          color:#fff;transform:rotate(90deg);box-shadow:0 6px 14px -6px rgba(139,26,26,.6)}
        .dt-menu{position:fixed;z-index:60;min-width:11rem;background:#fff;
          border:1px solid #E8E2D9;border-radius:.75rem;padding:.35rem;
          box-shadow:0 16px 36px -10px rgba(26,10,10,.28),0 2px 6px rgba(26,10,10,.06)}
        .dt-menu-title{padding:.35rem .65rem .45rem;font-size:.62rem;font-weight:700;
          letter-spacing:.1em;text-transform:uppercase;color:#9ca3af}
        .dt-menu div{display:flex!important;flex-direction:column!important;
          align-items:stretch!important;gap:.1rem!important;width:100%}
        .dt-menu button,.dt-menu a{display:flex!important;align-items:center!important;
          gap:.55rem!important;width:100%!important;padding:.5rem .65rem!important;
          font-size:.8rem!important;font-weight:500!important;color:#374151!important;
          background:transparent!important;border:none!important;border-radius:.45rem!important;
          text-align:left!important;cursor:pointer;text-decoration:none;
          transition:background .15s,color .15s,padding .15s}
        .dt-menu button:hover,.dt-menu a:hover{background:rgba(139,26,26,.08)!important;
          color:#8B1A1A!important;padding-left:.85rem!important}

        .dt-inline-actions{display:flex;align-items:center;gap:.5rem}

        /* ── Empty state ── */
        .dt-empty{padding:3rem 1rem;text-align:center;color:#9ca3af;font-size:.85rem}
        .dt-empty-icon{display:inline-flex;align-items:center;justify-content:center;
          width:3rem;height:3rem;border-radius:999px;margin-bottom:.6rem;color:#8B1A1A;
          background:rgba(139,26,26,.08)}

        @media (prefers-reduced-motion: reduce){
          .dt-row{animation:none}.dt-cell-icon,.dt-kebab{transition:none}
        }
      </style>

      <div class="dt-scroll">
        <table class="dt-table">
          <thead class="dt-head">
            <tr>
              <th :for={col <- @col} style={"text-align: #{col[:align] || "left"};"}>
                <span class="dt-th">
                  <span :if={col[:icon]} class="dt-th-icon">
                    <.icon name={col[:icon]} class="size-3.5" />
                  </span>
                  {col[:label]}
                </span>
              </th>
              <th :if={@has_actions?} style="text-align: right;">
                <span class="dt-th">
                  <span class="dt-th-icon"><.icon name="hero-cog-6-tooth" class="size-3.5" /></span>
                  {@actions_label}
                </span>
              </th>
            </tr>
          </thead>

          <tbody>
            <%= if @rows == [] do %>
              <tr>
                <td colspan={length(@col) + if(@has_actions?, do: 1, else: 0)}>
                  <div class="dt-empty">
                    <span class="dt-empty-icon"><.icon name="hero-inbox" class="size-6" /></span>
                    <p>{@empty_message}</p>
                  </div>
                </td>
              </tr>
            <% else %>
              <tr
                :for={{row, i} <- @indexed_rows}
                id={@row_id && @row_id.(row)}
                class={["dt-row", @row_click && "dt-row--clickable"]}
                style={"animation-delay: #{min(i, 12) * 35}ms;"}
              >
                <td
                  :for={col <- @col}
                  phx-click={@row_click && @row_click.(row)}
                  style={"text-align: #{col[:align] || "left"};"}
                >
                  <div
                    class="dt-cell"
                    style={
                      case col[:align] do
                        "right" -> "justify-content: flex-end;"
                        "center" -> "justify-content: center;"
                        _ -> ""
                      end
                    }
                  >
                    <span :if={col[:cell_icon] && col[:icon]} class="dt-cell-icon">
                      <.icon name={col[:icon]} class="size-4" />
                    </span>
                    <div>{render_slot(col, @row_item.(row))}</div>
                  </div>
                </td>

                <td :if={@has_actions?} style="text-align: right;">
                  <%= if @actions_variant == "inline" do %>
                    <div class="dt-inline-actions" style="justify-content: flex-end;">
                      {render_slot(@action, row)}
                    </div>
                  <% else %>
                    <.options_menu id={"#{@id}-menu-#{i}"} label={@actions_label}>
                      {render_slot(@action, row)}
                    </.options_menu>
                  <% end %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true
  attr :label, :string, default: "Options"
  slot :inner_block, required: true

  defp options_menu(assigns) do
    ~H"""
    <div
      style="display: inline-block;"
      phx-click-away={hide_menu(@id)}
    >
      <button
        type="button"
        id={"#{@id}-toggle"}
        class="dt-kebab"
        aria-haspopup="menu"
        aria-expanded="false"
        aria-controls={@id}
        aria-label={@label}
        onclick={position_script(@id)}
        phx-click={
          JS.toggle(
            to: "##{@id}",
            in: {"ease-out duration-150", "opacity-0 scale-95", "opacity-100 scale-100"},
            out: {"ease-in duration-100", "opacity-100 scale-100", "opacity-0 scale-95"}
          )
          |> JS.toggle_attribute({"aria-expanded", "true", "false"})
        }
      >
        <.icon name="hero-ellipsis-horizontal" class="size-4" />
      </button>

      <div
        id={@id}
        class="dt-menu"
        role="menu"
        style="display: none;"
        data-hide={hide_menu(@id)}
        onclick="if (event.target.closest('button, a') && window.liveSocket) { window.liveSocket.execJS(this, this.dataset.hide) }"
      >
        <p class="dt-menu-title">{@label}</p>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp hide_menu(id) do
    JS.hide(
      to: "##{id}",
      transition: {"ease-in duration-100", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
    |> JS.set_attribute({"aria-expanded", "false"}, to: "##{id}-toggle")
  end

  # The menu is position: fixed so the scrolling table can't clip it. This places
  # it under the button, or above it when there isn't room below.
  defp position_script(id) do
    """
    var r = this.getBoundingClientRect(), m = document.getElementById('#{id}');
    m.style.right = (window.innerWidth - r.right) + 'px';
    if (window.innerHeight - r.bottom < 220) {
      m.style.top = ''; m.style.bottom = (window.innerHeight - r.top + 6) + 'px';
      m.style.transformOrigin = 'bottom right';
    } else {
      m.style.bottom = ''; m.style.top = (r.bottom + 6) + 'px';
      m.style.transformOrigin = 'top right';
    }
    """
  end
end
