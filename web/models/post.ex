defmodule PhoenixBlog.Post do
  use PhoenixBlog.Web, :model

  schema "posts" do
    belongs_to :user, PhoenixBlog.User
    field :tittle, :string
    field :body, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tittle, :body])
    |> validate_required([:tittle, :body])
  end
end
