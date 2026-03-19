defmodule EnrouteHaye.PDFStore do
  @moduledoc """
  Temporary store for PDF payload tokens.

  Tokens expire after @ttl_seconds (default 5 minutes).
  The ETS table is owned by this GenServer so it survives
  individual LiveView crashes.

  Add to your supervision tree in application.ex:
      children = [
        ...
        EnrouteHaye.PDFStore,
        ...
      ]
  """

  use GenServer

  @table      :pdf_store
  @ttl_seconds 300   # 5 minutes
  @sweep_ms    60_000 # sweep expired tokens every 60 s

  # ── Public API ────────────────────────────────────────────────────────────

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc "Store a payload and return a URL-safe token."
  def put(payload) do
    token = generate_token()
    expires_at = System.system_time(:second) + @ttl_seconds
    :ets.insert(@table, {token, payload, expires_at})
    token
  end

  @doc "Retrieve a payload by token. Returns nil if missing or expired."
  def get(token) do
    now = System.system_time(:second)

    case :ets.lookup(@table, token) do
      [{^token, payload, expires_at}] when expires_at > now -> payload
      _ -> nil
    end
  end

  # ── GenServer callbacks ───────────────────────────────────────────────────

  @impl true
  def init(_) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    schedule_sweep()
    {:ok, %{}}
  end

  @impl true
  def handle_info(:sweep, state) do
    now = System.system_time(:second)
    :ets.select_delete(@table, [{{:_, :_, :"$1"}, [{:<, :"$1", now}], [true]}])
    schedule_sweep()
    {:noreply, state}
  end

  # ── Private ───────────────────────────────────────────────────────────────

  defp generate_token do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_ms)
  end
end
