defmodule EnrouteHaye.ItineraryPDF do
  alias Phoenix.View
  alias EnrouteHayeWeb.PdfView

  def generate(assigns) do
    html =
      View.render_to_string(
        PdfView,
        "itinerary.html",
        assigns
      )

    PdfGenerator.generate_binary(html,
      page_size: "A4",
      encoding: "UTF-8"
    )
  end
end
