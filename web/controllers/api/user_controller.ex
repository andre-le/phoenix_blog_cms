defmodule PhoenixBlog.Api.UserController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.User

  import Joken

  #put this in to validate with JWT
  #plug :authorize_user when action in [:index, :show]

  def index(conn, _params) do
    users = from(u in User, select: %{username: u.username, id: u.id, provider: u.provider, email: u.email, role: u.role_id})
    |> Repo.all
    json conn, users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    user = %{username: user.username, id: user.id, provider: user.provider, email: user.email, role: user.role_id}
    json conn, user
  end

  def verify(conn, %{"access_token" => token}) do
    request = HTTPotion.post "https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyAssertion?key=AIzaSyDAWqDfXKZkM-hBphL5Y58cnPhOVI4c7dg",
    [body: "{'postBody':'access_token=" <> token <>
    "&providerId=facebook.com', 'requestUri': 'http://localhost', 'returnIdpCredential':true,'returnSecureToken':true}",
    headers: ["Content-Type": "application/json"]]
    data = Poison.decode!(request.body)

    if data["error"] == nil do
      email = data["email"]
      username = data["displayName"]
      refreshToken = data["refreshToken"]

      unless user = Repo.get_by(User, email: email) do
        Repo.insert(%User{username: username, email: email, role_id: 1, refresh_token: refreshToken})
      end
      user = Repo.get_by(User, email: email)
      conn
      |> fetch_session
      |> put_session(:current_user, %{id: user.id, username: user.username, role_id: user.role_id})
      |> json %{data: data}
    else
      conn
      json conn, %{error: "Invalid Token"}
    end

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

end
