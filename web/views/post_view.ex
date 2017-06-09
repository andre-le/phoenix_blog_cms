defmodule PhoenixBlog.PostView do
  use PhoenixBlog.Web, :view
  alias PhoenixBlog.Repo
  alias PhoenixBlog.User
  alias PhoenixBlog.PostController

  def get_user(post) do
    user = Repo.get(User, post.user_id)
    user
  end

  def show_date(post) do
    post.updated_at
    |> String.Chars.to_string()
    |> String.slice(0, 10)
  end

  def get_comment_username(conn) do
    PostController.get_current_username(conn)
  end

end
