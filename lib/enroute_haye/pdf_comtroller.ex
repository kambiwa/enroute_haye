defmodule EnrouteHayeWeb.PDFController do
  @moduledoc """
  Renders the itinerary token into a PDF using wkhtmltopdf (temp-file strategy)
  and streams the result back to the browser.

  Route (in router.ex):
      get "/pdf/itinerary/:token", PDFController, :show
  """

  use EnrouteHayeWeb, :controller

  @wkhtmltopdf_args ~w(
    --quiet
    --enable-local-file-access
    --page-size      A4
    --margin-top     15mm
    --margin-bottom  15mm
    --margin-left    15mm
    --margin-right   15mm
    --print-media-type
    --encoding       UTF-8
  )

  # ── Action ────────────────────────────────────────────────────────────────

  def show(conn, %{"token" => token}) do
    case EnrouteHaye.PDFStore.get(token) do
      nil ->
        conn
        |> put_status(:not_found)
        |> text("Itinerary not found or expired.")

      payload ->
        case render_pdf(payload) do
          {:ok, pdf_bytes} ->
            name     = payload.traveller_name
            name_slug = if name, do: "_#{slug(name)}", else: ""
            filename = "enroute_haye_itinerary_#{slug(payload.city)}#{name_slug}.pdf"

            conn
            |> put_resp_content_type("application/pdf")
            |> put_resp_header("content-disposition", ~s(inline; filename="#{filename}"))
            |> send_resp(200, pdf_bytes)

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> text("PDF generation failed: #{reason}")
        end
    end
  end

  # ── Private: render via temp files ────────────────────────────────────────

  defp render_pdf(payload) do
    case System.find_executable("wkhtmltopdf") do
      nil ->
        {:error, "wkhtmltopdf is not installed on this server"}

      wkhtmltopdf ->
        # Unique prefix prevents collisions under concurrent requests
        uid       = Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
        html_path = Path.join(System.tmp_dir!(), "itinerary_#{uid}.html")
        pdf_path  = Path.join(System.tmp_dir!(), "itinerary_#{uid}.pdf")

        try do
          File.write!(html_path, build_html(payload))

          args = @wkhtmltopdf_args ++ [html_path, pdf_path]

          case System.cmd(wkhtmltopdf, args, stderr_to_stdout: true) do
            {_output, 0} ->
              {:ok, File.read!(pdf_path)}

            {output, code} ->
              {:error, "wkhtmltopdf exited #{code}: #{String.trim(output)}"}
          end
        after
          File.rm(html_path)
          File.rm(pdf_path)
        end
    end
  end

  # ── HTML template ─────────────────────────────────────────────────────────

  defp build_html(p) do
    foods  = names_for(p.foods_all, p.selected_foods)
    music  = names_for(p.music_all, p.selected_music)
    hotel  = p.hotel_name || "Not selected"
    city   = p.city || "Lusaka"
    date   = if p.start_date == "", do: "TBD", else: p.start_date
    sites  = length(p.active_pins)
    name   = p.traveller_name

    greeting =
      if name,
        do: "Dear #{name},",
        else: nil

    subtitle =
      if name,
        do: "Personalised for #{name} · #{city} · #{p.duration} Days",
        else: "Personalised Itinerary — #{city} · #{p.duration} Days"

    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <title>EnRoute Haye · Itinerary</title>
      <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
          font-family: Georgia, "Times New Roman", serif;
          font-size: 13px;
          color: #1a1a1a;
          background: #fff;
          line-height: 1.6;
        }

        .cover {
          background: #1E4035;
          color: #C9A84C;
          padding: 36px 40px 28px;
          margin-bottom: 28px;
        }
        .cover h1 { font-size: 28px; letter-spacing: 3px; margin-bottom: 4px; }
        .cover h1 span { color: #fff; }
        .cover .tagline { font-size: 11px; color: #a0c4ae; letter-spacing: 1px; }
        .cover .subtitle {
          margin-top: 14px;
          font-size: 15px;
          color: #fff;
          font-style: italic;
        }
        .cover .greeting {
          margin-top: 18px;
          font-size: 17px;
          color: #C9A84C;
          font-style: normal;
          font-weight: bold;
          letter-spacing: 0.5px;
        }
        .cover .name-badge {
          display: inline-block;
          margin-top: 6px;
          background: rgba(201,168,76,0.18);
          border: 1px solid #C9A84C;
          border-radius: 4px;
          padding: 3px 14px;
          font-size: 13px;
          color: #fff;
          letter-spacing: 1px;
        }

        .section { padding: 0 40px 20px; }
        .section-title {
          font-size: 11px;
          letter-spacing: 2px;
          text-transform: uppercase;
          color: #C9A84C;
          border-bottom: 1px solid #C9A84C;
          padding-bottom: 4px;
          margin-bottom: 12px;
        }

        .grid {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 10px 20px;
          margin-bottom: 8px;
        }
        .grid-item .label {
          font-size: 10px;
          text-transform: uppercase;
          letter-spacing: 1px;
          color: #888;
        }
        .grid-item .val {
          font-size: 13px;
          font-weight: bold;
          color: #1E4035;
        }

        .tag-list { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px; }
        .tag {
          background: #f0f5f2;
          border: 1px solid #c5d8ce;
          border-radius: 3px;
          padding: 2px 8px;
          font-size: 11px;
          color: #1E4035;
        }

        .cost-box {
          margin: 20px 40px;
          background: #1E4035;
          color: #C9A84C;
          border-radius: 6px;
          padding: 18px 24px;
          display: flex;
          align-items: baseline;
          gap: 16px;
        }
        .cost-box .amount { font-size: 32px; font-weight: bold; }
        .cost-box .range  { font-size: 11px; color: #a0c4ae; }

        .footer {
          margin-top: 32px;
          padding: 14px 40px;
          border-top: 1px solid #e0e0e0;
          font-size: 10px;
          color: #aaa;
          text-align: center;
        }

        @media print {
          body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
      </style>
    </head>
    <body>

      <div class="cover">
        <h1>ENROUTE <span>HAYE</span></h1>
        <div class="tagline">Digital Tour Guide · Zambia Cultural Journeys</div>
        <div class="subtitle">#{subtitle}</div>
        #{if greeting, do: ~s(<div class="greeting">#{greeting}</div><div class="name-badge">🎟️ TRAVELLER ITINERARY</div>), else: ""}
      </div>

      <div class="section">
        <div class="section-title">Journey Overview</div>
        <div class="grid">
          <div class="grid-item">
            <div class="label">Departure</div>
            <div class="val">#{city}</div>
          </div>
          <div class="grid-item">
            <div class="label">Start Date</div>
            <div class="val">#{date}</div>
          </div>
          <div class="grid-item">
            <div class="label">Duration</div>
            <div class="val">#{p.duration} Days</div>
          </div>
          <div class="grid-item">
            <div class="label">Transport</div>
            <div class="val">#{String.capitalize(p.transport)}</div>
          </div>
          <div class="grid-item">
            <div class="label">Ceremony</div>
            <div class="val">Kuomboka</div>
          </div>
          <div class="grid-item">
            <div class="label">Map Sites</div>
            <div class="val">#{sites} pinned</div>
          </div>
          <div class="grid-item">
            <div class="label">Accommodation</div>
            <div class="val">#{hotel}</div>
          </div>
          <div class="grid-item">
            <div class="label">Nightly Rate</div>
            <div class="val">$#{p.hotel_price} / night</div>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">Local Foods to Savour</div>
        <div class="tag-list">
          #{tag_items(foods, "No foods selected")}
        </div>
      </div>

      <div class="section">
        <div class="section-title">Cultural Music Playlist</div>
        <div class="tag-list">
          #{tag_items(music, "No tracks selected")}
        </div>
      </div>

      <div class="cost-box">
        <div class="amount">$#{p.total_cost}</div>
        <div class="range">Estimated total · #{city} · #{p.duration} nights</div>
      </div>

      <div class="footer">
        Generated by EnRoute Haye · enroutehaye.com · #{Date.utc_today()}
      </div>

    </body>
    </html>
    """
  end

  # ── Template helpers ──────────────────────────────────────────────────────

  defp names_for(all, selected_ids) do
    all
    |> Enum.filter(&(&1.id in selected_ids))
    |> Enum.map(& &1.name)
  end

  defp tag_items([], fallback),
    do: ~s(<span style="color:#aaa;">#{fallback}</span>)

  defp tag_items(names, _fallback),
    do: Enum.map_join(names, "\n", &~s(<span class="tag">#{&1}</span>))

  defp slug(city),
    do: city |> String.downcase() |> String.replace(~r/\s+/, "_")
end
