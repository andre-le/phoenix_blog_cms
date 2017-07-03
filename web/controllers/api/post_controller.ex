defmodule PhoenixBlog.Api.PostController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.Post
  alias PhoenixBlog.User
  alias PhoenixBlog.Comment
  import Joken

  plug :authorize_user when action in [:all]
  plug :authorize_user_in_index when action in [:index]
  plug :authorize_user_in_show when action in [:show]

  def index(conn, %{"user_id" => user_id}) do
    posts = from(post in Post, where: post.user_id == ^user_id,
    select: %{id: post.id, title: post.tittle, body: post.body, status: post.status, cover_image: post.image})
    |> Repo.all

    json conn, posts
  end

  def nondraft(conn, %{"user_id" => user_id}) do
    posts = from(post in Post, where: post.user_id == ^user_id and post.status != "Draft",
    select: %{id: post.id, title: post.tittle, body: post.body, status: post.status, cover_image: post.image})
    |> Repo.all

    json conn, posts
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    comments = from(comment in Comment, where: comment.post_id == ^id,
    select: comment.content) |> Repo.all
    post = %{id: post.id, title: post.tittle, body: post.body, status: post.status, cover_image: post.image, comments: comments}
    json conn, post
  end

  def all(conn, _params) do
    all_posts = from post in Post, where: post.status != "Draft"
    posts = from(post in all_posts,
    select: %{id: post.id, title: post.tittle, body: post.body, status: post.status, cover_image: post.image})
    |> Repo.all

    json conn, posts
  end

  def authorize_user(conn, _) do
    my_verified_token = get_req_header(conn, "authorization") |> to_string
    length = String.length(my_verified_token)
    my_verified_token = String.slice(my_verified_token, 7, length)
    |> token
    |> with_signer(hs256("wefit"))
    |> verify
    if my_verified_token.error == nil do
      conn
    else
      conn
      |> put_status(403)
      |> halt()
    end
  end

  defp authorize_user_in_index(conn, _) do
    my_verified_token = get_req_header(conn, "authorization") |> to_string
    length = String.length(my_verified_token)
    my_verified_token = String.slice(my_verified_token, 7, length)
    |> token
    |> with_signer(hs256("wefit"))
    |> verify
    if my_verified_token.error == nil do
      id = my_verified_token.claims["data"]["uid"]
      user = Repo.get!(User, conn.params["user_id"])
      if Integer.to_string(id) == conn.params["user_id"] do
        conn
      else
        conn
        |> redirect(to: api_user_post_path(conn, :nondraft, user))
      end
    else
      conn
      |> put_status(403)
      |> halt()
    end
  end

  defp authorize_user_in_show(conn, _) do
    my_verified_token = get_req_header(conn, "authorization") |> to_string
    length = String.length(my_verified_token)
    my_verified_token = String.slice(my_verified_token, 7, length)
    |> token
    |> with_signer(hs256("wefit"))
    |> verify
    if my_verified_token.error == nil do
      id = my_verified_token.claims["data"]["uid"]
      post = Repo.get!(Post, conn.params["id"])
      user = Repo.get!(User, conn.params["user_id"])
      if Integer.to_string(id) == conn.params["user_id"] or post.status != "Draft"  do
        conn
      else
        conn
        |> put_status(403)
        |> halt()
      end
    else
      conn
      |> put_status(403)
      |> halt()
    end
  end

end
