defmodule EnrouteHaye.Repo.Migrations.AddTripPlannerPersistence do
  use Ecto.Migration

  def change do
    alter table(:trips) do
      add :starting_province, :string
      add :starting_district, :string
      add :destination_province, :string
      add :destination_district, :string
      add :traveller_name, :string
      add :traveller_count, :integer, null: false, default: 1
      add :duration_days, :integer
      add :selected_event_id, references(:events, on_delete: :nilify_all)
      add :guest_token_hash, :binary
      add :currency, :string, null: false, default: "ZMW"
    end

    create unique_index(:trips, [:guest_token_hash])
    create index(:trips, [:user_id, :status, :updated_at])
    create index(:trip_stops, [:trip_id, :order_index])

    create table(:trip_transport_segments) do
      add :trip_id, references(:trips, on_delete: :delete_all), null: false
      add :mode, :string, null: false
      add :order_index, :integer, null: false, default: 0
      add :road_id, references(:roads, on_delete: :nilify_all)
      add :airline_id, references(:airline, on_delete: :nilify_all)
      add :estimated_cost, :decimal
      add :notes, :text
      timestamps(type: :utc_datetime)
    end

    create index(:trip_transport_segments, [:trip_id, :order_index])

    create table(:trip_food_selections) do
      add :trip_id, references(:trips, on_delete: :delete_all), null: false
      add :food_id, references(:foods, on_delete: :delete_all), null: false
      add :quantity, :integer, null: false, default: 1
      add :unit_price_estimate, :decimal
      timestamps(type: :utc_datetime)
    end

    create unique_index(:trip_food_selections, [:trip_id, :food_id])

    create table(:trip_audio_selections) do
      add :trip_id, references(:trips, on_delete: :delete_all), null: false
      add :audio_id, references(:audio, on_delete: :delete_all), null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:trip_audio_selections, [:trip_id, :audio_id])

    create table(:trip_accommodation_selections) do
      add :trip_id, references(:trips, on_delete: :delete_all), null: false
      add :accommodation_id, references(:accommodations, on_delete: :delete_all), null: false
      add :check_in, :date
      add :check_out, :date
      add :nightly_price_estimate, :decimal
      timestamps(type: :utc_datetime)
    end

    create unique_index(:trip_accommodation_selections, [:trip_id])

    create table(:trip_expenses) do
      add :trip_id, references(:trips, on_delete: :delete_all), null: false
      add :category, :string, null: false
      add :title, :string, null: false
      add :amount, :decimal, null: false
      add :currency, :string, null: false, default: "ZMW"
      add :price_type, :string, null: false, default: "estimated"
      add :notes, :text
      timestamps(type: :utc_datetime)
    end

    create index(:trip_expenses, [:trip_id, :category])
  end
end
