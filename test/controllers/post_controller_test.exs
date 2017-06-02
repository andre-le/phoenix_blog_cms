defmodule PhoenixBlog.PostControllerTest do
  use PhoenixBlog.ConnCase

  alias PhoenixBlog.Post

  alias PhoenixBlog.User
  setup do
    {:ok, user} = create_user
    conn = build_conn()
    |> login_user(user)
    {:ok, conn: conn, user: user}
  end
  defp create_user do
    User.changeset(%User{}, %{email: "test@test.com", username: "test", password: "test", password_confirmation: "test"})
    |> Repo.insert
  end
  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{username: user.username, password: user.password}
  end
  @valid_attrs %{body: "some content", tittle: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn, user: user} do
    conn = get conn, user_post_path(conn, :index, user)
    assert html_response(conn, 200) =~ "Listing posts"
  end

  test "renders form for new resources", %{conn: conn, user: user} do
    conn = get conn, user_post_path(conn, :new, user)
    assert html_response(conn, 200) =~ "New post"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert html_response(conn, 200) =~ "New post"
  end

  test "shows chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :show, post)
    assert html_response(conn, 200) =~ "Show post"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = get conn, post_path(conn, :edit, post)
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :show, post)
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit post"
  end

  test "deletes chosen resource", %{conn: conn} do
    post = Repo.insert! %Post{}
    conn = delete conn, post_path(conn, :delete, post)
    assert redirected_to(conn) == post_path(conn, :index)
    refute Repo.get(Post, post.id)
  end
end
