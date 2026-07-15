defmodule EnrouteHaye.Context.CxtMedia do
  alias EnrouteHaye.Schema.Media
  alias EnrouteHaye.Repo

  import Ecto.Query, warn: false

  # ── Paginated list (used by the LiveView index) ──────────────────────


  # ── Paginated list (used by the LiveView index) ──────────────────────

  def list_media(table_params \\ %{}, filters \\ %{}) do
    page        = EnrouteHayeWeb.Pagination.param_value(table_params, "page", 1)
    page_size   = EnrouteHayeWeb.Pagination.param_value(table_params, "page_size", 10)
    order_by    = table_params["order_by"] || %{"sort_field" => "id", "sort_direction" => "desc"}
    search      = get_in(table_params, ["filter", "isearch"]) || ""
    status      = filters[:status_filter] || filters["status_filter"] || ""

    Media
    |> apply_search(search)
    |> apply_status(status)
    |> apply_order(order_by)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def list_featured_videos(limit \\ 6) do
    Media
    |> where([m], not is_nil(m.file_path))
    |> where([m], fragment("? ILIKE ANY (?)", m.file_path, ["%.mp4", "%.mov", "%.webm"]))
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  # ── Standard CRUD ────────────────────────────────────────────────────

  def get_media!(id), do: Repo.get!(Media, id)

  def create_media(attrs \\ %{}) do
    %Media{}
    |> Media.changeset(attrs)
    |> Repo.insert()
  end

  def update_media(%Media{} = media, attrs) do
    media
    |> Media.changeset(attrs)
    |> Repo.update()
  end

  def delete_media(%Media{} = media) do
    Repo.delete(media)
  end

  def change_media(%Media{} = media, attrs \\ %{}) do
    Media.changeset(media, attrs)
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
