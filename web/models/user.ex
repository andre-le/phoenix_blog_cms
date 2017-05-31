defmodule PhoenixBlog.User do
  use PhoenixBlog.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_digest, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :password_digest])
    |> validate_required([:username, :email, :password_digest])
  end
end
