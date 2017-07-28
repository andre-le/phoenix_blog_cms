defmodule PhoenixBlog.SessionController do
  use PhoenixBlog.Web, :controller
  alias PhoenixBlog.User

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import JsonWebToken

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    user = get_session(conn, :current_user)
    if user == nil do
      render conn, "new.html", changeset: User.changeset(%User{})
    else
      conn
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))
    end
  end

  @doc """
  def create(conn, %{"user" => %{"username" => username, "password" => password}})
  when not is_nil(username) and not is_nil(password) do
    user = Repo.get_by(User, username: username)
    sign_in(user, password, conn)
  end
  """

  def create(conn, %{"user" => %{"email" => email, "password" => password}})
  when not is_nil(email) and not is_nil(password) do
    user = Repo.get_by(User, email: email)
    request = HTTPotion.post "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDAWqDfXKZkM-hBphL5Y58cnPhOVI4c7dg",
    [body: "{'email': '" <> email <> "', 'password': '" <> password <> "', 'returnSecureToken': true}",
    headers: ["Content-Type": "application/json"]]
    data = Poison.decode!(request.body)
    token = data['idToken']
    sign_in(request, user, token, conn)
  end

  def create(conn, _) do
    failed_login(conn)
  end

  defp sign_in(_request, user, _token, conn) when is_nil(user) do
   failed_login(conn)
  end

  defp sign_in(request, user, token, conn) do
    if HTTPotion.Response.success?(request) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username, role_id: user.role_id})
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))

    else
      failed_login(conn)
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Signed out successfully!")
    |> redirect(to: page_path(conn, :index))
  end

  defp failed_login(conn) do
    conn
    |> put_session(:current_user, nil)
    |> put_flash(:error, "Invalid username/password combination!")
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end

  defp verified_token(token) do
    {:ok, claims} = JsonWebToken.verify(token, %{alg: "RS256", key: "d314873e2afe2927d767e7a77c517d547e9b74ce"})
  end

end
