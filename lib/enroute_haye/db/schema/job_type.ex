defmodule EnrouteHaye.Schema.JobType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_types" do
    field :title, :string
    field :is_active, :boolean, default: true
    has_many :approval_work_flow, EnrouteHaye.ApprovalWorkFlows.ApprovalWorkFlow
    has_one :job, EnrouteHaye.Jobs.Job

    timestamps(
      type: :naive_datetime,
      autogenerate: {EnrouteHaye.LocalTimestamp, :autogenerate, []}
    )
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:title, :is_active])
    |> validate_inclusion(:title, ["Officer", "Senior Officer", "Manager", "Director", "External"])
    |> validate_required([:title])
  end
end
