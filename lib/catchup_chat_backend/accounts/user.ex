defmodule CatchupChatBackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true
    field :name, :string
    field :last_coordinates, :map
    field :is_admin, :boolean, default: false
    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :name, :last_coordinates])
    |> validate_required([:email, :password])
    |> put_default_last_coordinates()
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:email, max: 160)
    |> validate_length(:password, min: 8, max: 20)
    |> validate_length(:name, min: 1, max: 10)
    |> unsafe_validate_unique(:email, CatchupChatBackend.Repo)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp put_default_last_coordinates(changeset) do
    case get_change(changeset, :last_coordinates) do
      nil -> put_change(changeset, :last_coordinates, %{})
      _ -> changeset
    end
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end
end
