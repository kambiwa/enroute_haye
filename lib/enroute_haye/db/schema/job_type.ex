defmodule EnrouteHaye.Schema.JobType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_types" do
    field :title, :string
    field :is_active, :boolean, default: true
    has_many :jobs, EnrouteHaye.Schema.Job

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :is_active])
    |> validate_inclusion(:title, ["Officer", "Senior Officer", "Manager", "Director", "External"])
    |> validate_required([:title])
  end
end
