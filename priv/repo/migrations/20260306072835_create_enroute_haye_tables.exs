defmodule EnrouteHaye.Repo.Migrations.CreateEnrouteHayeTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    # ========================
    # USERS 
    # ========================
    create table(:users) do
      # Auth fields
      add :email, :citext, null: false
      add :hashed_password, :string
      add :confirmed_at, :utc_datetime

      # Profile fields
      add :name, :string
      add :role, :string, default: "tourist"
      add :avatar, :string
      add :country, :string
      add :bio, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])

    # ========================
    # USER TOKENS (AUTH)
    # ========================
    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    # ========================
    # TRIPS
    # ========================
    create table(:trips) do
      add :title, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :budget_estimate, :decimal
      add :status, :string, default: "draft"

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    # ========================
    # SITES
    # ========================
    create table(:sites) do
      add :name, :string
      add :description, :text
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :category, :string
      add :image_url, :string

      timestamps(type: :utc_datetime)
    end

    # ========================
    # TRIP STOPS
    # ========================
    create table(:trip_stops) do
      add :day_number, :integer
      add :order_index, :integer
      add :notes, :text

      add :trip_id, references(:trips, on_delete: :delete_all)
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    # ========================
    # EVENTS
    # ========================
    create table(:events) do
      add :title, :string
      add :description, :text
      add :event_date, :date
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :image_url, :string

      timestamps(type: :utc_datetime)
    end

    # ========================
    # ACCOMMODATIONS
    # ========================
    create table(:accommodations) do
      add :name, :string
      add :description, :text
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :price_per_night, :decimal
      add :rating, :float
      add :contact_email, :string
      add :contact_phone, :string
      add :image_url, :string

      timestamps(type: :utc_datetime)
    end

    # ========================
    # BOOKINGS
    # ========================
    create table(:bookings) do
      add :check_in, :date
      add :check_out, :date
      add :total_price, :decimal
      add :status, :string, default: "pending"

      add :user_id, references(:users, on_delete: :delete_all)
      add :accommodation_id, references(:accommodations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    # ========================
    # FOODS
    # ========================
    create table(:foods) do
      add :name, :string
      add :description, :text
      add :region, :string
      add :image_url, :string

      timestamps(type: :utc_datetime)
    end

    # ========================
    # AUDIO
    # ========================
    create table(:audio) do
      add :title, :string
      add :artist, :string
      add :description, :text
      add :file_url, :string
      add :duration, :integer
      add :cover_image, :string
      add :category, :string

      timestamps(type: :utc_datetime)
    end

    # ========================
    # MEDIA
    # ========================
    create table(:media) do
      add :file_url, :string
      add :type, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    # ========================
    # REVIEWS
    # ========================
    create table(:reviews) do
      add :rating, :integer
      add :comment, :text

      add :user_id, references(:users, on_delete: :delete_all)
      add :accommodation_id, references(:accommodations, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    # ========================
    # FAVORITES
    # ========================
    create table(:favorites) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
