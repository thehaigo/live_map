defmodule LiveMapWeb.Api.UserView do
  use LiveMapWeb, :view

  def render("jwt.json", %{token: token}) do
    %{token: token}
  end
end
