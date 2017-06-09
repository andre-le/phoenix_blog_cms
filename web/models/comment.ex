defmodule PhoenixBlog.Comment do
  use PhoenixBlog.Web, :model

  schema "comments" do
    field :content, :string
    belongs_to :post, PhoenixBlog.Post, foreign_key: :post_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end
