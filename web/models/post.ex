defmodule PhoenixBlog.Post do
  use PhoenixBlog.Web, :model
  use Rummage.Ecto

  schema "posts" do
    belongs_to :user, PhoenixBlog.User
    has_many :comments, PhoenixBlog.Comment
    field :image, :string
    field :tittle, :string
    field :body, :string
    field :status, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:tittle, :body, :image, :status])
    |> validate_required([:tittle, :body])
    |> strip_unsafe_body(params)
  end

  defp strip_unsafe_body(model, %{"body" => nil}) do
    model
  end

  defp strip_unsafe_body(model, %{"body" => body}) do
    {:safe, clean_body} = Phoenix.HTML.html_escape(body)
    model |> put_change(:body, clean_body)
  end

  defp strip_unsafe_body(model, _) do
    model
  end

end
