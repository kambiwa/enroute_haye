defmodule EnrouteHayeWeb.Datatable.Table do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns = assign(assigns, :has_actions?, not Enum.empty?(assigns.action))

    ~H"""
    <div
      id="table-container"
      style="background: #fff; border: 1px solid #E8E2D9; border-radius: 0.75rem; overflow: hidden;"
    >
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse; font-size: 0.83rem;">

          <%!-- ── Header ── --%>
          <thead>
            <tr style="background: #FAF8F5;">
              <th
                :for={col <- @col}
                style="padding: 0.65rem 1.25rem; text-align: left; font-size: 0.68rem;
                       font-weight: 600; color: #9ca3af; text-transform: uppercase;
                       letter-spacing: 0.08em; white-space: nowrap;
                       border-bottom: 1px solid #E8E2D9;"
              >
                <%= col[:label] %>
              </th>

              <%= if @has_actions? do %>
                <th style="padding: 0.65rem 1.25rem; text-align: left; font-size: 0.68rem;
                           font-weight: 600; color: #9ca3af; text-transform: uppercase;
                           letter-spacing: 0.08em; white-space: nowrap;
                           border-bottom: 1px solid #E8E2D9;">
                  Actions
                </th>
              <% end %>
            </tr>
          </thead>

          <%!-- ── Body ── --%>
          <tbody>
            <%= if Enum.empty?(@rows) do %>
              <tr>
                <td
                  colspan={length(@col) + if(@has_actions?, do: 1, else: 0)}
                  style="padding: 2.5rem; text-align: center; color: #9ca3af; font-size: 0.85rem;"
                >
                  No records found
                </td>
              </tr>
            <% else %>
              <tr
                :for={row <- @rows}
                id={@row_id && @row_id.(row)}
                style="border-top: 1px solid #E8E2D9;"
                onmouseover="this.style.background='#FAF8F5'"
                onmouseout="this.style.background='transparent'"
              >
                <td
                  :for={{col, _i} <- Enum.with_index(@col)}
                  phx-click={@row_click && @row_click.(row)}
                  style={"padding: 0.8rem 1.25rem; white-space: nowrap; color: #4b5563;#{if @row_click, do: " cursor: pointer;", else: ""}"}
                >
                  <div>{render_slot(col, @row_item.(row))}</div>
                </td>

                <%= if @has_actions? do %>
                  <td style="padding: 0.8rem 1.25rem; white-space: nowrap;">
                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                      {render_slot(@action, row)}
                    </div>
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>

        </table>
      </div>
    </div>
    """
  end
end
