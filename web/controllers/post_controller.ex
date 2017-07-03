defmodule PhoenixBlog.PostController do

  use PhoenixBlog.Web, :controller
  use Rummage.Phoenix.Controller

  alias PhoenixBlog.Post
  alias PhoenixBlog.Comment

  plug :scrub_params, "comment" when action in [:add_comment]
  plug :assign_user
  plug :authorize_user when action in [:new, :create, :update, :edit, :delete]
  plug :authorize_draft when action in [:index]

  def index(conn, params) do
    {query, rummage} = assoc(conn.assigns[:user], :posts)
    |> Post.rummage(params["rummage"])
    posts = Repo.all(query)
    render(conn, "index.html", posts: posts, rummage: rummage)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    changeset =
      conn.assigns[:user]
      |> build_assoc(:posts)
      |> Post.changeset(post_params)
    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: user_post_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    changeset = post
    |> build_assoc(:comments)
    |> PhoenixBlog.Comment.changeset()
    #Get all the comments in the post
    query = from comment in Comment, where: comment.post_id == ^id
    comments = Repo.all(query)
    render(conn, "show.html", post: post, comment: comments, changeset: changeset)
  end

  def page(conn, %{"post_id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    changeset = Post.changeset(post)
    render(conn, "page.html", post: post, changeset: changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    user = get_session(conn, :current_user)
    changeset = Post.changeset(post, post_params)
    if (post_params["status"] == "Publish" && user.role_id == 1) do
      conn
      |> put_flash(:error, "You are not authorized to publish post")
      |> redirect(to: user_post_path(conn, :edit, conn.assigns[:user], post))
    else
      case Repo.update(changeset) do
        {:ok, post} ->
          conn
          |> put_flash(:info, "Post updated successfully.")
          |> redirect(to: user_post_path(conn, :show, conn.assigns[:user], post))
        {:error, changeset} ->
          render(conn, "edit.html", post: post, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(assoc(conn.assigns[:user], :posts), id)
    query = from cmt in Comment, where: cmt.post_id == ^id
    Repo.delete_all(query)
    Repo.delete!(post)
    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: user_post_path(conn, :index, conn.assigns[:user]))
  end

  def nondraft(conn, _) do
    query = from post in assoc(conn.assigns[:user], :posts),
    where: post.status != "Draft"
    posts = Repo.all(query)
    render(conn, "nondrafts.html", posts: posts)
  end

  def all(conn, params) do
    all_posts = from post in Post, where: post.status != "Draft"
    {query, rummage} = all_posts
    |> Post.rummage(params["rummage"])
    posts = Repo.all(query)

    render(conn, "nondrafts.html", posts: posts, rummage: rummage)
  end

  defp assign_user(conn, _opts) do
    case conn.params do
      %{"user_id" => user_id} ->
        case Repo.get(PhoenixBlog.User, user_id) do
          nil  -> invalid_user(conn)
          user -> assign(conn, :user, user)
        end
      _ -> invalid_user(conn)
    end
  end

  defp invalid_user(conn) do
    conn
    |> put_flash(:error, "Invalid user!")
    |> redirect(to: page_path(conn, :index))
    |> halt
  end

  defp authorize_user(conn, _) do
    user = get_session(conn, :current_user)
    if user && (Integer.to_string(user.id) == conn.params["user_id"]
    || PhoenixBlog.RoleChecker.is_admin?(user)) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp authorize_draft(conn, _) do
    user = get_session(conn, :current_user)
    if user && Integer.to_string(user.id) != conn.params["user_id"] do
      conn
      |> redirect(to: user_post_path(conn, :nondraft, conn.assigns[:user]))
    else
      conn
    end
  end

  def add_comment(conn, %{"comment" => comment_params, "post_id" => post_id}) do
    post      = Repo.get!(Post, post_id) |> Repo.preload([:user, :comments])
    changeset = post
      |> build_assoc(:comments)
      |> Comment.changeset(comment_params)
    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment created successfully!")
        |> redirect(to: user_post_path(conn, :show, post.user, post))
      {:error, changeset} ->
        render(conn, "show.html", post: post, changeset: changeset)
    end
  end

  def get_current_username(conn) do
    user = get_session(conn, :current_user)
    user.username
  end
end
