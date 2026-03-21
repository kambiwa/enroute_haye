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
            name      = payload.traveller_name
            name_slug = if name, do: "_#{slug(name)}", else: ""
            filename  = "kuomboka_itinerary_#{slug(payload.city)}#{name_slug}.pdf"

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
        uid       = Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
        html_path = Path.join(System.tmp_dir!(), "itinerary_#{uid}.html")
        pdf_path  = Path.join(System.tmp_dir!(), "itinerary_#{uid}.pdf")

        try do
          File.write!(html_path, build_html(payload))

          args = @wkhtmltopdf_args ++ [html_path, pdf_path]

          case System.cmd(wkhtmltopdf, args, stderr_to_stdout: true) do
            {_output, 0}      -> {:ok, File.read!(pdf_path)}
            {output, code}    -> {:error, "wkhtmltopdf exited #{code}: #{String.trim(output)}"}
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
      if name, do: "Dear #{name},", else: nil

    subtitle =
      if name,
        do: "Personalised for #{name} · #{city} · #{p.duration} Days",
        else: "Personalised Itinerary — #{city} · #{p.duration} Days"

    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8" />
      <title>Kuomboka · Itinerary</title>
      <style>
        /* ── Reset ── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        /* ── Base ── */
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
          font-size: 13px;
          color: #0A0A0A;
          background: #FFFFFF;
          line-height: 1.6;
        }

        /* ── Cover ── */
        .cover {
          background: #0A0A0A;
          color: #FFFFFF;
          padding: 40px 44px 32px;
          margin-bottom: 0;
          position: relative;
          overflow: hidden;
        }

        /* Diagonal red accent strip — mirrors the hero section */
        .cover::after {
          content: '';
          position: absolute;
          top: 0; right: 0;
          width: 36%;
          height: 100%;
          background: #CC0000;
          clip-path: polygon(20% 0, 100% 0, 100% 100%, 0% 100%);
        }

        .cover-inner { position: relative; z-index: 1; }

        .cover-eyebrow {
          font-size: 10px;
          letter-spacing: 0.3em;
          text-transform: uppercase;
          color: #CC0000;
          font-weight: 600;
          margin-bottom: 10px;
        }

        .cover h1 {
          font-family: Georgia, "Times New Roman", serif;
          font-size: 36px;
          font-weight: 700;
          letter-spacing: 0.08em;
          color: #FFFFFF;
          line-height: 1;
          margin-bottom: 6px;
        }

        .cover-divider {
          display: flex;
          align-items: center;
          gap: 10px;
          margin: 14px 0;
        }
        .cover-divider-line {
          width: 48px;
          height: 2px;
          background: #CC0000;
          display: inline-block;
        }
        .cover-divider-icon {
          color: #CC0000;
          font-size: 1rem;
        }
        .cover-divider-line-faint {
          width: 48px;
          height: 2px;
          background: rgba(255,255,255,0.15);
          display: inline-block;
        }

        .cover-subtitle {
          font-size: 13px;
          color: rgba(255,255,255,0.6);
          font-style: italic;
          margin-bottom: 16px;
        }

        .cover-greeting {
          font-family: Georgia, "Times New Roman", serif;
          font-size: 18px;
          color: #FFFFFF;
          font-weight: 700;
          margin-bottom: 6px;
        }

        .cover-badge {
          display: inline-block;
          border: 1.5px solid rgba(204,0,0,0.5);
          padding: 3px 14px;
          font-size: 10px;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: #CC0000;
          margin-top: 4px;
        }

        /* ── Red rule under cover ── */
        .cover-rule {
          height: 3px;
          background: #CC0000;
        }

        /* ── Sections ── */
        .section {
          padding: 22px 44px 16px;
          border-bottom: 1px solid #F0EFED;
        }
        .section:last-of-type { border-bottom: none; }

        .section-title {
          font-size: 9px;
          letter-spacing: 0.25em;
          text-transform: uppercase;
          color: #CC0000;
          font-weight: 700;
          border-bottom: 1.5px solid #CC0000;
          padding-bottom: 5px;
          margin-bottom: 14px;
        }

        /* ── Overview grid ── */
        .grid {
          display: grid;
          grid-template-columns: 1fr 1fr 1fr;
          gap: 12px 24px;
        }
        .grid-item .label {
          font-size: 9px;
          text-transform: uppercase;
          letter-spacing: 0.15em;
          color: #8A8780;
          margin-bottom: 2px;
        }
        .grid-item .val {
          font-family: Georgia, "Times New Roman", serif;
          font-size: 13px;
          font-weight: 700;
          color: #0A0A0A;
        }

        /* ── Tags ── */
        .tag-list { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 4px; }
        .tag {
          background: #F2F0EB;
          border: 1px solid #DDDBD6;
          border-left: 3px solid #CC0000;
          padding: 3px 10px;
          font-size: 11px;
          color: #1A1A1A;
        }
        .tag-empty { font-size: 11px; color: #B8B5AF; font-style: italic; }

        /* ── Cost box ── */
        .cost-box {
          margin: 0 44px 24px;
          background: #0A0A0A;
          color: #FFFFFF;
          border-top: 3px solid #CC0000;
          padding: 20px 28px;
          display: flex;
          align-items: baseline;
          gap: 20px;
        }
        .cost-label {
          font-size: 9px;
          letter-spacing: 0.2em;
          text-transform: uppercase;
          color: #CC0000;
          margin-bottom: 4px;
        }
        .cost-amount {
          font-family: Georgia, "Times New Roman", serif;
          font-size: 38px;
          font-weight: 700;
          color: #FFFFFF;
          line-height: 1;
        }
        .cost-range {
          font-size: 11px;
          color: rgba(255,255,255,0.45);
          margin-top: 4px;
        }

        /* ── Footer ── */
        .footer {
          margin-top: 20px;
          padding: 14px 44px;
          border-top: 1px solid #DDDBD6;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-size: 9px;
          color: #B8B5AF;
          letter-spacing: 0.08em;
        }
        .footer-brand {
          font-family: Georgia, "Times New Roman", serif;
          color: #CC0000;
          font-weight: 700;
          letter-spacing: 0.15em;
          text-transform: uppercase;
          font-size: 10px;
        }

        @media print {
          body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
        }
      </style>
    </head>
    <body>

      <div class="cover">
        <div class="cover-inner">
          <div class="cover-eyebrow">The Royal Journey · Digital Itinerary</div>
          <h1>KUOMBOKA</h1>

          <div class="cover-divider">
            <span class="cover-divider-line"></span>
            <span class="cover-divider-icon">〰</span>
            <span class="cover-divider-line-faint"></span>
          </div>

          <div class="cover-subtitle">#{subtitle}</div>

          #{if greeting do
            ~s(<div class="cover-greeting">#{greeting}</div><div class="cover-badge">✦ Traveller Itinerary</div>)
          else
            ""
          end}
        </div>
      </div>
      <div class="cover-rule"></div>

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
            <div class="val">#{sites} Pinned</div>
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
        <div>
          <div class="cost-label">Estimated Total</div>
          <div class="cost-amount">$#{p.total_cost}</div>
          <div class="cost-range">#{city} · #{p.duration} nights</div>
        </div>
      </div>

      <div class="footer">
        <span class="footer-brand">♛ Kuomboka</span>
        <span>Generated #{Date.utc_today()} · kuomboka.zm</span>
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
    do: ~s(<span class="tag-empty">#{fallback}</span>)

  defp tag_items(names, _fallback),
    do: Enum.map_join(names, "\n", &~s(<span class="tag">#{&1}</span>))

  defp slug(str),
    do: str |> String.downcase() |> String.replace(~r/\s+/, "_")
end
