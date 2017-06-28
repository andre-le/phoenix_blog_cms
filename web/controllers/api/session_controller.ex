defmodule PhoenixBlog.Api.SessionController do
  use PhoenixBlog.Web, :controller
  alias PhoenixBlog.User

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Joken

  def create(conn, %{"username" => username, "password" => password})
  when not is_nil(username) and not is_nil(password) do
    user = Repo.get_by(User, username: username)
    sign_in(user, password, conn)
  end

  def create(conn, _) do
    failed_login(conn)
  end

  def decrypt_jwt(conn, _) do
    my_verified_token = get_req_header(conn, "authorization") |> to_string
    length = String.length(my_verified_token)
    my_verified_token = String.slice(my_verified_token, 7, length)
    |> token
    |> with_signer(hs256("wefit"))
    |> verify
    json conn, my_verified_token
  end

  defp sign_in(user, _password, conn) when is_nil(user) do
    failed_login(conn)
  end

  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      my_token = %{status: "success", data: %{uid: user.id, provider: user.provider}}
      |> token
      |> with_signer(hs256("wefit"))
      |> sign
      |> get_compact
      json conn, %{status: "success", data: %{type: "jwt", "token": my_token}}
    else
      failed_login(conn)
    end
  end

  defp failed_login(conn) do
    json conn, %{status: "error", data: nil, message: "Failed login"}
  end

end
