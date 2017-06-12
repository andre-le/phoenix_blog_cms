defmodule PhoenixBlog.Post do
  use PhoenixBlog.Web, :model
  use Rummage.Ecto

  schema "posts" do
    belongs_to :user, PhoenixBlog.User
    has_many :comments, PhoenixBlog.Comment
    field :tittle, :string
    field :body, :string
    field :draft, :boolean, default: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tittle, :body, :draft])
    |> validate_required([:tittle, :body])
  end
end
