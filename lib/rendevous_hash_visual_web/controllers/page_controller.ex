defmodule RendevousHashVisualWeb.PageController do
  use RendevousHashVisualWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
