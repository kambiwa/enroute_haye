# defmodule EnrouteHayeWeb.MerchantsLive.FormComponent do
#   use EnrouteHayeWeb, :live_component
#   # import Phoenix.HTML.Form
#   require Logger

#   # alias EnrouteHayeWeb.Accounts.Merchant
#   alias EnrouteHayeWeb.Accounts

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <div class="bg-probase-light p-6 rounded-xl mt-8 max-w-4xl mx-auto">
#       <!-- Orange Border Line -->
#       <div class="h-1 bg-orange-500 mb-4"></div>

#       <div class="border-b border-probase-dark pb-4 mb-6">
#         <h2 class="text-2xl font-bold text-probase-dark">{@title}</h2>
#       </div>

#       <.form
#         for={@form}
#         phx-target={@myself}
#         phx-change="validate"
#         phx-submit="save"
#         class="space-y-6"
#       >
#         <!-- Section 1: Merchant Details -->
#         <div>
#           <div class="grid grid-cols-2 gap-6">
#             <div>
#               <.input
#                 field={@form[:firstname]}
#                 label="First Name"
#                 placeholder="Enter Contact First Name"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:lastname]}
#                 label="Last Name"
#                 placeholder="Enter Contact Last Name"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:user_name]}
#                 label="Company Name"
#                 placeholder="Enter Company Name"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:email]}
#                 label="Contact Email"
#                 placeholder="Enter email"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:mobile_number]}
#                 label="Mobile Number"
#                 placeholder="Enter Mobile Number"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:description]}
#                 label="Description"
#                 placeholder="Enter Description"
#                 required
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#             <div>
#               <.input
#                 field={@form[:country]}
#                 type="select"
#                 label="Country"
#                 options={[
#                   {"Select Country", ""},
#                   {"Zambia", "zambia"},
#                   {"Other", "other"}
#                 ]}
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>

#             <div>
#               <.input
#                 field={@form[:city]}
#                 type="select"
#                 label="City"
#                 options={[
#                   {"Select City", ""},
#                   {"Lusaka", "lusaka"},
#                   {"Kabwe", "kabwe"},
#                   {"Kitwe", "kitwe"},
#                   {"Ndola", "ndola"},
#                   {"Other", "other"}
#                 ]}
#                 class="w-full p-2 border border-gray-300 rounded-md"
#               />
#             </div>
#           </div>

#         </div>

#     <!-- Submit Button -->
#         <div class="mt-6 flex justify-end">
#           <button
#             type="submit"
#             class="rounded-lg bg-blue-800 px-6 py-3 text-sm font-semibold text-white hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2"
#           >
#             {if @action == :new, do: "Create Merchant", else: "Save Changes"}
#           </button>
#         </div>
#       </.form>
#     </div>
#     """
#   end

#   @impl true
#   def update(%{merchant: merchant} = assigns, socket) do
#     {:ok,
#      socket
#      |> assign(assigns)
#      |> assign_new(:form, fn ->
#        to_form(Accounts.change_merchant_registration(merchant))
#      end)}
#   end

#   @impl true
#   def handle_event("validate", %{"merchant" => merchant_params}, socket) do
#     changeset =
#       socket.assigns.merchant
#       |> Accounts.change_merchant_registration(merchant_params)
#       |> Map.put(:action, :validate)

#     {:noreply, assign(socket, form: to_form(changeset))}
#   end

#   @impl true
#   def handle_event("save", %{"merchant" => merchant_params}, socket) do
#     save_merchant(socket, socket.assigns.action, merchant_params)
#   end

#   defp save_merchant(socket, :edit, merchant_params) do
#     case Accounts.update_merchant(socket.assigns.merchant, merchant_params) do
#       {:ok, merchant} ->
#         notify_parent({:saved, merchant})

#         {:noreply,
#          socket
#          |> put_flash(:info, "Merchant updated successfully")
#          |> push_patch(to: socket.assigns.patch)}

#       {:error, %Ecto.Changeset{} = changeset} ->
#         {:noreply, assign(socket, form: to_form(changeset))}
#     end
#   end

#   defp save_merchant(socket, :new, merchant_params) do
#     case Accounts.register_merchant(merchant_params) do
#       {:ok, merchant} ->
#         notify_parent({:saved, merchant})

#         {:noreply,
#          socket
#          |> put_flash(:info, "Merchant created successfully")
#          |> push_patch(to: socket.assigns.patch)}

#       {:error, %Ecto.Changeset{} = changeset} ->
#         {:noreply, assign(socket, form: to_form(changeset))}

#       _error ->
#         {:noreply,
#          socket
#          |> put_flash(:error, "An unexpected error occurred")}
#     end
#   end

#   defp notify_parent(msg) do
#     send(self(), {__MODULE__, msg})
#   end
# end
