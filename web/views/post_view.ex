defmodule PhoenixBlog.PostView do
  use PhoenixBlog.Web, :view
  alias PhoenixBlog.Repo
  alias PhoenixBlog.User

  def get_username(post) do
    user = Repo.get(User, post.user_id)
    user.username
  end

  def show_date(post) do
    post.updated_at
    |> String.Chars.to_string()
    |> String.slice(0, 10)
  end

end
