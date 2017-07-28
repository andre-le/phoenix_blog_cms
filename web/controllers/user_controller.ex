defmodule PhoenixBlog.UserController do
  use PhoenixBlog.Web, :controller
  use Rummage.Phoenix.Controller

  alias PhoenixBlog.User
  alias PhoenixBlog.Role
  alias PhoenixBlog.Post

  plug :authorize_admin when action in [:new, :create]
  plug :authorize_user when action in [:edit, :update, :delete]

  def index(conn, params) do
    {query, rummage} = User
    |> User.rummage(params["rummage"])
    users = Repo.all(query)

    render(conn, "index.html", users: users, rummage: rummage)
  end

  def new(conn, _params) do
    roles = Repo.all(Role)
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset, roles: roles)
  end

  def create(conn, %{"user" => user_params}) do
    roles = Repo.all(Role)
    changeset = User.changeset(%User{}, user_params)

    #POST request to Firebase API
    request = HTTPotion.post "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDAWqDfXKZkM-hBphL5Y58cnPhOVI4c7dg",
    [body: "{'email': '" <> user_params["email"] <> "', 'password': '" <> user_params["password"] <> "', 'returnSecureToken': true}",
    headers: ["Content-Type": "application/json"]]
    data = Poison.decode!(request.body)

    if HTTPotion.Response.success?(request) do
      id = data["refreshToken"]
      changeset = User.change_refresh_token(changeset, id)
      case Repo.insert(changeset) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "User created successfully.")
          |> redirect(to: user_path(conn, :index))
        {:error, changeset} ->
          render(conn, "new.html", changeset: changeset, roles: roles)
      end
    else
      message = data["error"]["message"]
      conn
      |> put_flash(:error, message)
      |> render("new.html", changeset: changeset, roles: roles)
    end

  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    roles = Repo.all(Role)
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset, roles: roles)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    roles = Repo.all(Role)
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset, roles: roles)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    query = from(post in Post, where: post.user_id == ^id, select: %{tittle: post.tittle})
    |> Repo.all
    if (query == []) do
      Repo.delete!(user)
      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: user_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Canot delete! This user still has posts")
      |> redirect(to: user_path(conn, :index))
    end
  end

  defp authorize_user(conn, _) do
    user = get_session(conn, :current_user)
    if user && (Integer.to_string(user.id) == conn.params["id"] || PhoenixBlog.RoleChecker.is_admin?(user)) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that user!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp authorize_admin(conn, _) do
    user = get_session(conn, :current_user)
    if user && PhoenixBlog.RoleChecker.is_admin?(user) do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to create new users!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

end
