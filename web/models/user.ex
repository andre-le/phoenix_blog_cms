defmodule PhoenixBlog.User do
  use PhoenixBlog.Web, :model
  use Rummage.Ecto
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    belongs_to :role, PhoenixBlog.Role
    has_many :posts, PhoenixBlog.Post
    field :username, :string
    field :email, :string
    field :password_digest, :string
    field :uid, :string
    field :provider, :string

    timestamps()

    # Virtual Fields
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password, :password_confirmation, :role_id, :uid, :provider])
    |> validate_required([:username, :email, :password, :password_confirmation, :role_id])
    |> hash_password
    |> get_provider
  end

  #apply to user log in with WeFit
  defp get_provider(changeset) do
      changeset
      |> put_change(:provider, "WeFit")
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:password_digest, hashpwsalt(password))
    else
      changeset
    end
  end
end
