defmodule EnrouteHaye.Context.CxtAudio do
  alias EnrouteHaye.Schema.Audio
  alias EnrouteHaye.Repo

  import Ecto.Query, warn: false

  def list_audios(table_params \\ %{}, filters \\ %{}) do
    page      = EnrouteHayeWeb.Pagination.param_value(table_params, "page", 1)
    page_size = EnrouteHayeWeb.Pagination.param_value(table_params, "page_size", 10)
    order_by  = table_params["order_by"] || %{"sort_field" => "id", "sort_direction" => "desc"}
    search    = get_in(table_params, ["filter", "isearch"]) || ""
    status    = filters[:status_filter] || filters["status_filter"] || ""

    Audio
    |> apply_search(search)
    |> apply_status(status)
    |> apply_order(order_by)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # ── Standard CRUD ────────────────────────────────────────────────────

  def get_audio!(id), do: Repo.get!(Audio, id)
  def get_track!(id), do: Repo.get!(Audio, id)

  def create_audio(attrs \\ %{}) do
    %Audio{}
    |> Audio.changeset(attrs)
    |> Repo.insert()
  end

  def update_audio(%Audio{} = audio, attrs) do
    audio
    |> Audio.changeset(attrs)
    |> Repo.update()
  end

  def delete_audio(%Audio{} = audio) do
    Repo.delete(audio)
  end

  def change_audio(%Audio{} = audio, attrs \\ %{}) do
    Audio.changeset(audio, attrs)
  end

  # ── Private query helpers ────────────────────────────────────────────

  defp apply_search(query, ""),   do: query
  defp apply_search(query, nil),  do: query
  defp apply_search(query, search) do
    term = "%#{search}%"
    # Search across title, artist, and description
    where(
      query,
      [a],
      ilike(a.title, ^term) or
      ilike(a.artist, ^term) or
      ilike(a.description, ^term)
    )
  end

  defp apply_status(query, ""),   do: query
  defp apply_status(query, nil),  do: query
  defp apply_status(query, status) do
    where(query, [a], a.status == ^status)
  end

  defp apply_order(query, %{"sort_field" => field, "sort_direction" => "asc"}) do
    order_by(query, [a], asc: field(a, ^String.to_existing_atom(field)))
  end
  defp apply_order(query, %{"sort_field" => field, "sort_direction" => "desc"}) do
    order_by(query, [a], desc: field(a, ^String.to_existing_atom(field)))
  end
end
