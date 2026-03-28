# defmodule EnrouteHayeWeb.MerchantLive do
#   use EnrouteHayeWeb, :live_view

#   alias EnrouteHayeWeb.Datatable.Table
#   alias EnrouteHayeWeb.Accounts.Merchant
#   alias EnrouteHayeWeb.Pagination
#   alias EnrouteHayeWeb.Accounts

#   @impl true
#   def mount(_params, _session, socket) do
#     socket =
#       socket
#       |> assign(:page_title, "Merchants")
#       |> assign(:data_loader, false)
#       |> assign(:data, [])
#       |> assign(:data_pagenations, [])
#       |> assign(filter_expanded: false)
#       |> assign(:status_filter, "")
#       |> assign(:search_filter, "")
#       |> assign(:merchant, %Merchant{})
#       |> Pagination.order_by_composer()
#       |> Pagination.i_search_composer()

#     {:ok, socket}
#   end

#   @impl true
#   def handle_params(params, _url, socket) do
#     {:noreply,
#      socket
#      |> assign(params: %{})
#      |> apply_action(socket.assigns.live_action, params)}
#   end

#   defp apply_action(socket, :edit, %{"id" => id}) do
#     socket
#     |> assign(:page_title, "Edit merchant")
#     |> assign(:merchant, Accounts.get_merchant!(id))
#   end

#   defp apply_action(socket, :new, _params) do
#     socket
#     |> assign(:page_title, "New Merchants")
#     |> assign(:merchant, %Merchant{})
#   end

#   defp apply_action(socket, :index, _params) do
#     socket
#     |> assign(:page_title, "Merchants")
#     |> assign(:merchant, nil)
#     |> fetch_filtered_merchants()
#   end

#   @impl true
#   def handle_info(
#         {LicenseAppWeb.MerchantsLive.FormComponent, {:saved, _merchant}},
#         socket
#       ) do
#     {:noreply,
#      socket
#      |> fetch_filtered_merchants()}
#   end

#   @impl true
#   def handle_event("add_merchant", _params, socket) do
#     {:noreply,
#      socket
#      |> assign(:page_title, "New Merchant")
#      |> assign(:merchant, %Merchant{})
#      |> assign(:live_action, :new)}
#   end

#   def handle_event("edit", %{"id" => id}, socket) do
#     {:noreply,
#      socket
#      |> assign(:page_title, "Edit Merchant")
#      |> assign(:merchant, Accounts.get_merchant!(id))
#      |> assign(:live_action, :edit)}
#   end

#   @impl true
#   def handle_event("close", _params, socket) do
#     {:noreply,
#      socket
#      |> assign(:live_action, :index)}
#   end

#   @impl true
#   def handle_event("toggle-filter", _, socket) do
#     {:noreply, assign(socket, filter_expanded: !socket.assigns.filter_expanded)}
#   end

#   @impl true
#   def handle_event("filter", %{"filter" => filters} = _params, socket) do
#     {:noreply,
#      socket
#      |> assign(:status_filter, filters["status_filter"])
#      |> assign(:search_filter, filters["search_filter"])
#      |> fetch_filtered_merchants()}
#   end

#   @impl true
#   def handle_event("export-excel", _params, socket) do
#     merchants = Accounts.list_merchants(%{})
#     excel_content = generate_excel(merchants)

#     {:noreply,
#      socket
#      |> push_event("download-excel", %{
#        content: excel_content,
#        filename: "merchants_#{Date.utc_today()}.xlsx"
#      })}
#   end

#   @impl true
#   def handle_event("export-pdf", _params, socket) do
#     merchants = Accounts.list_merchants(%{})
#     pdf_content = generate_pdf(merchants)

#     {:noreply,
#      socket
#      |> push_event("download-pdf", %{
#        content: pdf_content,
#        filename: "merchants_#{Date.utc_today()}.pdf"
#      })}
#   end

#   defp fetch_filtered_merchants(socket) do
#     filters = %{
#       search_filter: socket.assigns.search_filter,
#       status_filter: socket.assigns.status_filter
#     }

#     data =
#       Accounts.list_merchants(
#         Pagination.create_table_params(socket, socket.assigns.params),
#         filters
#       )

#     socket
#     |> assign(:data, data.entries)
#     |> assign(:data_pagenations, Map.drop(data, [:entries]))
#     |> assign(data_loader: false)
#   end

#   defp generate_excel(_merchants) do
#     "Not implemented yet"
#   end

#   defp generate_pdf(_merchants) do
#     "Not implemented yet"
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <!-- Main Content -->
#           <!-- Header with Filter Toggle and Export Buttons -->
#     <div class="flex flex-col sm:flex-row sm:items-start justify-between mb-6">
#       <div class="sm:flex-auto space-y-4">
#         <!-- Filter Button -->
#         <button
#           phx-click="toggle-filter"
#           class="inline-flex items-center px-4 py-2 text-sm font-semibold text-white bg-gradient-to-r from-[#1e2a4a] to-[#2d3c61] rounded-lg hover:from-[#2d3c61] hover:to-[#1e2a4a] transition-all duration-300"
#         >
#           <i class="fa-solid fa-filter mr-2"></i> Filter
#         </button>
#       </div>

#       <div class="mt-4 sm:mt-0 flex items-center space-x-3">

#     <!-- Add merchant  -->
#         <button
#           phx-click="add_merchant"
#           class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-brand border border-transparent rounded-lg hover:bg-brand-dark focus:outline-none focus:ring-2 focus:ring-brand focus:ring-offset-2 transition-colors duration-150"
#         >
#           <i class="fas fa-plus mr-2"></i> New Merchant
#         </button>
#       </div>
#     </div>

#     <!-- Filter Section with Smooth Transition -->
#     <div class={[
#       "overflow-hidden transition-all duration-500 ease-in-out mb-6",
#       @filter_expanded && "max-h-[500px] opacity-100",
#       !@filter_expanded && "max-h-0 opacity-0"
#     ]}>
#       <div class="bg-white shadow rounded-lg p-6 relative">
#         <!-- Gradient Border -->
#         <div class="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-brand via-brand-light to-brand rounded-t-lg">
#         </div>

#         <div
#           class="form-container"
#           style="max-height: 300px; max-width: 1000px; overflow-y: auto; margin: 0 auto;"
#         >
#           <.form for={%{}} as={:filter} phx-change="filter" class="space-y-6">
#             <div class="grid grid-cols-1 gap-x-6 gap-y-4 sm:grid-cols-3">
#               <div>
#                 <label class="block text-sm font-medium text-gray-700">Search</label>
#                 <.input
#                   name="filter[search_filter]"
#                   placeholder="Search..."
#                   value={@search_filter}
#                   class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-gray-900 focus:border-brand focus:outline-none focus:ring-brand sm:text-sm"
#                 />
#               </div>

#               <div>
#                 <label class="block text-sm font-medium text-gray-700">Status</label>
#                 <.input
#                   type="select"
#                   name="filter[status_filter]"
#                   prompt="All"
#                   options={[{"ACTIVE", "active"}, {"INACTIVE", "inactive"}]}
#                   value={@status_filter}
#                   class="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-gray-900 focus:border-brand focus:outline-none focus:ring-brand sm:text-sm"
#                 />
#               </div>
#             </div>
#           </.form>
#         </div>
#       </div>
#     </div>

#     <!-- Table Section -->
#     <div class="bg-white shadow rounded-lg overflow-hidden">
#       <Table.table id="tbl_merchants" rows={@data}>
#         <:col :let={merchant} label="Name">{merchant.name}</:col>
#         <:col :let={merchant} label="Description">{merchant.description}</:col>
#         <:col :let={merchant} label="Location">{merchant.city}, {merchant.country}</:col>
#         <:col :let={merchant} label="Email">{merchant.email}</:col>
#         <:col :let={merchant} label="Contact Number">{merchant.mobile_number}</:col>
#         <:col :let={merchant} label="Status">
#           <span class={"inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{status_badge_class(merchant.status)}"}>
#             {is_active_badge(merchant.status)}
#           </span>
#         </:col>
#         <:action :let={merchant}>
#           <.link
#             phx-click="edit"
#             phx-value-id={merchant.id}
#             class="inline-flex items-center px-3 py-1.5 text-xs font-medium rounded-md text-amber-700 bg-amber-100 hover:bg-amber-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 transition-colors duration-150 mx-2"
#           >
#             <i class="fa-solid fa-pen w-3 h-3 mr-1"></i> Edit
#           </.link>
#         </:action>
#       </Table.table>
#       <%= if @data_loader do %>
#         <div class="py-8 text-center">
#           <div class="flex justify-center items-center">
#             <svg
#               xmlns="http://www.w3.org/2000/svg"
#               class="animate-spin h-8 w-8 text-[#0f172a]"
#               fill="none"
#               viewBox="0 0 24 24"
#             >
#               <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
#               </circle>
#               <path
#                 class="opacity-75"
#                 fill="currentColor"
#                 d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
#               >
#               </path>
#             </svg>
#           </div>
#         </div>
#       <% else %>
#         <%= if Enum.empty?(@data) do %>
#           <div class="py-8 text-center">
#             <svg
#               xmlns="http://www.w3.org/2000/svg"
#               class="h-12 w-12 mx-auto text-gray-400"
#               fill="none"
#               viewBox="0 0 24 24"
#               stroke="currentColor"
#               stroke-width="2"
#             >
#               <path
#                 stroke-linecap="round"
#                 stroke-linejoin="round"
#                 d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
#               />
#             </svg>
#             <span class="block mt-2 text-gray-500">No merchants found</span>
#           </div>
#         <% end %>
#       <% end %>
#       <!-- Pagination -->
#       <.live_component
#         module={LicenseAppWeb.PaginationComponent}
#         id="PaginationComponent"
#         params={@params}
#         pagination_data={@data_pagenations}
#       />
#     </div>

#     <!-- Modal -->
#     <%= if @live_action in [:new, :edit] do %>
#       <.modal
#         id={"crud-merchant-modal-#{@merchant.id || :new}"}
#         show
#         on_cancel={JS.patch(~p"/u/merchants")}
#       >
#         <.live_component
#           module={LicenseAppWeb.MerchantsLive.FormComponent}
#           id={@merchant.id || :new}
#           title={@page_title}
#           action={@live_action}
#           merchant={@merchant}
#           patch={~p"/u/merchants"}
#         />
#       </.modal>
#     <% end %>
#     """
#   end
# end
