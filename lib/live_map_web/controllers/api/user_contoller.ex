defmodule LiveMapWeb.Api.UserController do
  use LiveMapWeb, :controller

  alias LiveMap.Accounts

  def sign_in(conn, %{"email" => email, "password" => password }) do
    with { :ok, token, _claims } <- Accounts.token_sign_in(email, password) do
      conn |> render("jwt.json", token: token)
    end
  end

  def sign_in(conn, %{ "token" => token}) do
    with {:ok, jwt, _claims } <- Accounts.one_time_signin(token) do
      conn |> render("jwt.json", token: jwt)
    end
  end
end
