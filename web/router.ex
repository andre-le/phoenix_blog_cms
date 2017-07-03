defmodule PhoenixBlog.Router do
  use PhoenixBlog.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PhoenixBlog.Api, as: :api do
    pipe_through :api

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show] do
      resources "/posts", PostController, only: [:index, :show]
      get "/all", PostController, :all
      get "/nondrafts", PostController, :nondraft
    end
    post "/sessions", SessionController, :create
    get "/sessions", SessionController, :decrypt_jwt

  end

  scope "/", PhoenixBlog do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController do
      resources "/posts", PostController do
        post "/comment", PostController, :add_comment
        get "/page", PostController, :page
      end
      get "/nondrafts", PostController, :nondraft
      get "/all", PostController, :all

    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixBlog do
  #   pipe_through :api
  # end
end
