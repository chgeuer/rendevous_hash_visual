defmodule RendevousHashVisualWeb.Router do
  use RendevousHashVisualWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RendevousHashVisualWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RendevousHashVisualWeb do
    pipe_through :browser

    # get "/", PageController, :home
    live "/", InteractiveSvgLive, :index
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:rendevous_hash_visual, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RendevousHashVisualWeb.Telemetry
    end
  end
end
