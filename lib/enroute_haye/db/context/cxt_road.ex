defmodule EnrouteHaye.Context.CxtRoad do
  alias EnrouteHaye.Schema.Road
  alias EnrouteHaye.Repo

  import Ecto.Query, warn: false

  # ── Paginated list (used by the LiveView index) ──────────────────────

  def list_bus_operators(table_params \\ %{}, filters \\ %{}) do
    page        = EnrouteHayeWeb.Pagination.param_value(table_params, "page", 1)
    page_size   = EnrouteHayeWeb.Pagination.param_value(table_params, "page_size", 10)
    order_by    = table_params["order_by"] || %{"sort_field" => "id", "sort_direction" => "desc"}
    search      = get_in(table_params, ["filter", "isearch"]) || ""
    status      = filters[:status_filter] || filters["status_filter"] || ""

    Road
    |> apply_search(search)
    |> apply_status(status)
    |> apply_order(order_by)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # ── province and district ────────────────────────────────────────────────────
    def list_provinces do
      [
        "Central Province", "Copperbelt Province", "Eastern Province",
        "Luapula Province", "Lusaka Province", "Muchinga Province",
        "Northern Province", "North-Western Province", "Southern Province",
        "Western Province"
      ]
    end

    def list_districts(nil), do: []

    def list_districts(""), do: []

    def list_districts(province) do
      case province do
        "Central Province"       -> ["Chibombo","Chisamba","Chitambo","Chongwe","Kabwe","Kapiri Mposhi","Luano","Mumbwa","Ngabwe","Serenje"]
        "Copperbelt Province"    -> ["Chililabombwe","Chingola","Kalulushi","Kitwe","Luanshya","Lufwanyama","Masaiti","Mpongwe","Mufulira"]
        "Eastern Province"       -> ["Chipata","Katete","Lundazi","Mambwe","Nyimba"]
        "Luapula Province"       -> ["Chienge","Chilubi","Chongwe","Mansa","Milenge","Mwense","Nchelenge"]
        "Lusaka Province"        -> ["Chilanga","Chongwe","Kafue","Luangwa","Lusaka"]
        "Muchinga Province"      -> ["Chinsali","Isoka","Mpika","Nakonde"]
        "Northern Province"      -> ["Kaputa","Kasama","Luwingu","Mbala","Mpulungu","Mporokoso","Senga Hill"]
        "North-Western Province" -> ["Chavuma","Kabompo","Kalumbila","Kasempa","Mufumbwe","Mwinilunga","Solwezi"]
        "Southern Province"      -> ["Choma","Gwembe","Kalomo","Kazungula","Livingstone","Mazabuka","Monze","Namwala","Pemba","Siavonga"]
        "Western Province"       -> ["Kalabo","Kaoma","Luampa","Lukulu","Mongu","Mitete","Mulobezi","Senanga","Sesheke","Shangombo"]
        _ -> []
      end
    end

    # Fetch road operators departing from a district
    def list_roads_from(district) when is_binary(district) and district != "" do
      Road
      |> where([r], r.departure_point == ^district)
      |> order_by([r], asc: r.departure_time)
      |> Repo.all()
    end

   def list_roads_from(_), do: []

  # ── Standard CRUD ────────────────────────────────────────────────────


  def get_road_operator!(id), do: Repo.get!(Road, id)

  def create_road_operator(attrs \\ %{}) do
    %Road{}
    |> Road.changeset(attrs)
    |> Repo.insert()
  end

  def update_road_operator(%Road{} = road, attrs) do
    road
    |> Road.changeset(attrs)
    |> Repo.update()
  end

  def delete_road_operator(%Road{} = road) do
    Repo.delete(road)
  end

  def change_road_operator(%Road{} = road, attrs \\ %{}) do
    Road.changeset(road, attrs)
  end

  # ── Private query helpers ────────────────────────────────────────────

  defp apply_search(query, ""), do: query
  defp apply_search(query, nil), do: query
  defp apply_search(query, search) do
    term = "%#{search}%"
    where(query, [f], ilike(f.name, ^term) or ilike(f.description, ^term))
  end

  defp apply_status(query, ""), do: query
  defp apply_status(query, nil), do: query
  defp apply_status(query, status) do
    where(query, [f], f.status == ^status)
  end

  defp apply_order(query, %{"sort_field" => field, "sort_direction" => direction}) do
    order = if direction == "asc", do: :asc, else: :desc

    case field do
      "name"        -> order_by(query, [f], [{^order, f.name}])
      "status"      -> order_by(query, [f], [{^order, f.status}])
      "inserted_at" -> order_by(query, [f], [{^order, f.inserted_at}])
      _             -> order_by(query, [f], [{^order, f.id}])
    end
  end

  defp apply_order(query, _), do: order_by(query, [f], desc: f.id)


end
