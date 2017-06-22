defmodule PhoenixBlog.PageController do
  use PhoenixBlog.Web, :controller
  alias PhoenixBlog.Post

  def index(conn, _params) do
    x = Repo.all(Post)
    posts = from(post in Post, where: post.publish == true)
    |> Repo.all
    render(conn, "index.html", posts: x)
  end

end
