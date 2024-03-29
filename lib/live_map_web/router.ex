defmodule LiveMapWeb.Router do
  use LiveMapWeb, :router

  import LiveMapWeb.UserAuth

  alias LiveMapWeb.ApiAuthPipeline
  alias LiveMapWeb.AuthHelper

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveMapWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug ApiAuthPipeline
    plug AuthHelper
  end

  pipeline :sp_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
    plug :put_root_layout, {LiveMapWeb.LayoutView, :sp}
  end


  scope "/", LiveMapWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  scope "/sp", LiveMapWeb do
    pipe_through [:sp_browser, :jwt_authenticated]
    get "/:id", MapsController, :index
  end

  scope "/sp", LiveMapWeb do
    pipe_through [:sp_browser ,:require_authenticated_user]
    live "/maps/:id", MapLive.Map, :show
  end

  # Other scopes may use custom stacks.
  scope "/api", LiveMapWeb do
    pipe_through :api

    post "/sign_in", Api.UserController, :sign_in
  end

  scope "/api", LiveMapWeb do
    pipe_through [:api, :jwt_authenticated]

    resources "/maps", Api.MapController, only: [:index, :show, :create]
    resources "/points", Api.PointController, only: [:create]
    post "/users/refresh_token", Api.UserController, :refresh_token
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: LiveMapWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", LiveMapWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", LiveMapWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    post "/users/settings/gen_token", UserSettingsController, :gen_token
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email

    live "/maps", MapLive.Index, :index
    live "/maps/new", MapLive.Index, :new
    live "/maps/:id/edit", MapLive.Index, :edit

    live "/maps/:id", MapLive.Show, :show
    live "/maps/:id/show/edit", MapLive.Show, :edit
  end

  scope "/", LiveMapWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :confirm
  end
end
