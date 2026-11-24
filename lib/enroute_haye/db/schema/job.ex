defmodule EnrouteHaye.Schema.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :title, :string
    field :description, :string
    field :status, :string

    belongs_to :job_type, EnrouteHaye.Schema.JobType

    belongs_to :department, EnrouteHaye.Schema.Department
    field :is_active, :boolean, default: true
    timestamps()
  end

  def changeset(jobs, attrs) do
    jobs
    |> cast(attrs, [
      :title,
      :job_type_id,
      :description,
      :status,
      :is_active,
      :department_id
    ])
    |> validate_required([:title, :job_type_id, :department_id])
  end
end
