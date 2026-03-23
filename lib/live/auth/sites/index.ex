defmodule EnrouteHayeWeb.Auth.Sites.Index do
   use EnrouteHayeWeb, :live_view



   def mount(_params, _session, socket) do

    socket =
      socket
      |> assign(:page_title, "Sites")
      # |> assign(:accommodations, EnrouteHaye.Accommodations.list_accommodations())

    {:ok, socket}
   end

   def render(assigns) do
    ~H"""
    <Layouts.admin_app flash={@flash} current_scope={@current_scope} current_page={:sites}>
        <%!-- <div class="container mx-auto px-4 py-8">

          <div class="bg-white shadow-md rounded-lg p-6">
            <h1 class="text-2xl font-bold mb-4">Accommodations</h1>

            <div class="mb-4">
              <.link navigate={~p"/accomodations/new"} class="btn btn-primary">
                New Accommodation
              </.link>
            </div>

            <div class="overflow-x-auto">
              <table class="min-w-full bg-white border border-gray-200">
                <thead>
                  <tr>
                    <th class="py-2 px-4 border-b">Name</th>
                    <th class="py-2 px-4 border-b">Location</th>
                    <th class="py-2 px-4 border-b">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for accommodation <- @accommodations do %>
                    <tr>
                      <td class="py-2 px-4 border-b"><%= accommodation.name %></td>
                      <td class="py-2 px-4 border-b"><%= accommodation.location %></td>
                      <td class="py-2 px-4 border-b">
                        <.link navigate={~p"/accomodations/#{accommodation.id}/edit"} class="btn btn-sm btn-secondary">
                          Edit
                        </.link>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        </div> --%>
    </Layouts.admin_app>
    """
end



end
