defmodule Microblog.Blog.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Microblog.Blog.User


  schema "users" do
    field :email, :string
    field :username, :string
    field :password_hash, :string
    field :pw_tries, :integer
    field :pw_last_try, :utc_datetime
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_confirmation(:password)
    |> validate_password(:password)
    #|> validate_required([:email, :password_hash])
    |> put_pass_hash()
  end

  # Password validation
  # From Comeonin docs
  def validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case valid_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

   def put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Comeonin.Argon2.add_hash(password, hash_key: :password_hash))
  end
  def put_pass_hash(changeset), do: changeset

  def valid_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end
  def valid_password?(_), do: {:error, "The password is too short"}
end