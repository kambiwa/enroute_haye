defmodule EnrouteHaye.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true


    # belongs_to :role, EnrouteHaye.User.Role
    belongs_to :job, EnrouteHaye.Schema.Job

    field :confirmed_at, :utc_datetime

    field :authenticated_at, :utc_datetime, virtual: true

    timestamps(type: :utc_datetime)
  end

  ## ======================
  ## REGISTRATION
  ## ======================

    def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :job_id, :password])
    |> validate_required([:email, :password])
    |> validate_email()
    |> validate_password()
    |> unique_constraint(:email)
    # remove unless you truly want job_id unique per user:
    # |> unsafe_validate_unique(:job_id, EnrouteHaye.Repo)
  end

  ## ======================
  ## EMAIL
  ## ======================

 def email_changeset(user, attrs, opts \\ []) do
      user
      |> cast(attrs, [:email])
      |> validate_email(opts)
    end
  defp validate_email(changeset, opts \\ []) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)

    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:email, EnrouteHaye.Repo)
      |> unique_constraint(:email)
      # removed: |> validate_required([:job_id])
    else
      changeset
    end
  end

  ## ======================
  ## PASSWORD
  ## ======================

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts \\ []) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> validate_length(:password, max: 72, count: :bytes)
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  ## ======================
  ## PASSWORD VERIFY
  ## ======================

  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end
end
