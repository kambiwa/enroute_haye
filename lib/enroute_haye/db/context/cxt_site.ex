defmodule EnrouteHaye.Context.CxtSite do
  alias EnrouteHaye.Schema.Site
  alias EnrouteHaye.Repo

  import Ecto.Query, warn: false

  # ── Paginated list (used by the LiveView index) ──────────────────────

  def list_sites(table_params \\ %{}, filters \\ %{}) do
    page        = EnrouteHayeWeb.Pagination.param_value(table_params, "page", 1)
    page_size   = EnrouteHayeWeb.Pagination.param_value(table_params, "page_size", 10)
    order_by    = table_params["order_by"] || %{"sort_field" => "id", "sort_direction" => "desc"}
    search      = get_in(table_params, ["filter", "isearch"]) || ""
    status      = filters[:status_filter] || filters["status_filter"] || ""

    Site
    |> apply_search(search)
    |> apply_status(status)
    |> apply_order(order_by)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # ── Standard CRUD ────────────────────────────────────────────────────

  def get_site!(id), do: Repo.get!(Site, id)

  def create_site(attrs \\ %{}) do
    %Site{}
    |> Site.changeset(attrs)
    |> Repo.insert()
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
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
  defp apply_order(query, %{"sort_field" => field, "sort_direction" => "asc"}) do
    order_by(query, [f], asc: field(f, ^String.to_existing_atom(field)))
  end
  defp apply_order(query, %{"sort_field" => field, "sort_direction" => "desc"}) do
    order_by(query, [f], desc: field(f, ^String.to_existing_atom(field)))
  end
end
