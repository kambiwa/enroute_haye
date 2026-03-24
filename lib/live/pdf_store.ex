defmodule EnrouteHaye.PDFStore do
  use GenServer
  require Logger

  @table       :pdf_store
  @ttl_seconds 300
  @sweep_ms    60_000

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def put(payload) do
    GenServer.call(__MODULE__, {:put, payload})
  end

  def get(token) do
    now = System.system_time(:second)

    case :ets.lookup(@table, token) do
      [{^token, payload, expires_at}] when expires_at > now -> payload
      _ -> nil
    end
  end

  @impl true
  def init(_) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
      Logger.info("[PDFStore] ETS table created")
    else
      Logger.info("[PDFStore] ETS table already exists, reusing")
    end

    schedule_sweep()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:put, payload}, _from, state) do
    token = generate_token()
    expires_at = System.system_time(:second) + @ttl_seconds
    :ets.insert(@table, {token, payload, expires_at})
    {:reply, token, state}
  end

  @impl true
  def handle_info(:sweep, state) do
    now = System.system_time(:second)
    :ets.select_delete(@table, [{{:_, :_, :"$1"}, [{:<, :"$1", now}], [true]}])
    schedule_sweep()
    {:noreply, state}
  end

  defp generate_token do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, @sweep_ms)
  end
end
