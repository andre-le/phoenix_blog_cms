defmodule PhoenixBlog.Api.UserController do
  use PhoenixBlog.Web, :controller

  alias PhoenixBlog.User
  alias PhoenixBlog.Role

  def index(conn, _params) do
    users = from(u in User, select: %{username: u.username, email: u.email, role: u.role_id})
    |> Repo.all
    json conn, users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    user = %{username: user.username, email: user.email, role: user.role_id}
    json conn, user
  end

end
