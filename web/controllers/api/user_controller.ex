defmodule PhoenixBlog.Api.UserController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.User

  import Joken

  plug :authorize_user when action in [:index, :show]

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
