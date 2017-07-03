defmodule PhoenixBlog.Api.PageController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.Post

  def index(conn, params) do
    posts = from(post in Post, where: post.status == "Publish",
    select: %{id: post.id, title: post.tittle, body: post.body, status: post.status, cover_image: post.image})
    |> Repo.all
    json conn, posts
  end
end
