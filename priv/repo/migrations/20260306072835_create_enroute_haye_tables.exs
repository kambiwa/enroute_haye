defmodule EnrouteHaye.Repo.Migrations.CreateEnrouteHayeTables do
  use Ecto.Migration

  def change do

    # USERS
    create table(:users) do
      add :name, :string
      add :email, :string
      add :hashed_password, :string
      add :role, :string, default: "tourist"
      add :avatar, :string
      add :country, :string
      add :bio, :text

      timestamps()
    end

    create unique_index(:users, [:email])


    # TRIPS / ITINERARIES
    create table(:trips) do
      add :title, :string
      add :description, :text
      add :start_date, :date
      add :end_date, :date
      add :budget_estimate, :decimal
      add :status, :string, default: "draft"

      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end


    # DESTINATIONS / SITES
    create table(:sites) do
      add :name, :string
      add :description, :text
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :category, :string
      add :image_url, :string

      timestamps()
    end


    # TRIP STOPS (MAP PINS)
    create table(:trip_stops) do
      add :day_number, :integer
      add :order_index, :integer
      add :notes, :text

      add :trip_id, references(:trips, on_delete: :delete_all)
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end


    # CULTURAL EVENTS
    create table(:events) do
      add :title, :string
      add :description, :text
      add :event_date, :date
      add :location, :string
      add :latitude, :float
      add :longitude, :float
      add :image_url, :string

      timestamps()
    end


    # ACCOMMODATION
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

      timestamps()
    end


    # BOOKINGS
    create table(:bookings) do
      add :check_in, :date
      add :check_out, :date
      add :total_price, :decimal
      add :status, :string, default: "pending"

      add :user_id, references(:users, on_delete: :delete_all)
      add :accommodation_id, references(:accommodations, on_delete: :delete_all)

      timestamps()
    end


    # LOCAL FOODS
    create table(:foods) do
      add :name, :string
      add :description, :text
      add :region, :string
      add :image_url, :string

      timestamps()
    end


    # MUSIC LIBRARY
    create table(:audio) do
      add :title, :string
      add :artist, :string
      add :description, :text
      add :file_url, :string
      add :duration, :integer
      add :cover_image, :string
      add :category, :string

      timestamps()
    end


    # MEDIA FILES
    create table(:media) do
      add :file_url, :string
      add :type, :string
      add :description, :text

      timestamps()
    end


    # REVIEWS
    create table(:reviews) do
      add :rating, :integer
      add :comment, :text

      add :user_id, references(:users, on_delete: :delete_all)
      add :accommodation_id, references(:accommodations, on_delete: :delete_all)

      timestamps()
    end


    # FAVORITES
    create table(:favorites) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :site_id, references(:sites, on_delete: :delete_all)

      timestamps()
    end

  end
end
