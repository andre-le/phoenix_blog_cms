defmodule PhoenixBlog.PageController do
  use PhoenixBlog.Web, :controller
  alias PhoenixBlog.Post

  def index(conn, _params) do
    posts = from(post in Post, where: post.status == "Publish")
    |> Repo.all
    render(conn, "index.html", posts: posts)
  end

end
