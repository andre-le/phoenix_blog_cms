defmodule PhoenixBlog.Api.PostController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.Post
  alias PhoenixBlog.Comment

  def index(conn, %{"user_id" => user_id}) do
    posts = from(post in Post, where: post.user_id == ^user_id and post.draft == false,
    select: %{title: post.tittle, body: post.body, draft: post.draft, cover_image: post.image})
    |> Repo.all

    json conn, posts
  end

  def show(conn, %{"id" => id}) do#need fix
    post = Repo.get!(Post, id)
    comments = from(comment in Comment, where: comment.post_id == ^id,
    select: comment.content) |> Repo.all
    post = %{title: post.tittle, body: post.body, draft: post.draft, cover_image: post.image, comments: comments}
    json conn, post
  end

  def all(conn, _params) do
    all_posts = from post in Post, where: post.draft == false
    posts = from(post in all_posts,
    select: %{title: post.tittle, body: post.body, draft: post.draft, cover_image: post.image})
    |> Repo.all

    json conn, posts
  end

end
