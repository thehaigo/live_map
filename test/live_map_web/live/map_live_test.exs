defmodule LiveMapWeb.MapLiveTest do
  use LiveMapWeb.ConnCase

  import Phoenix.LiveViewTest

  alias LiveMap.Loggers

  @create_attrs %{description: "some description", name: "some name"}
  @update_attrs %{description: "some updated description", name: "some updated name"}
  @invalid_attrs %{description: nil, name: nil}

  defp fixture(:map) do
    {:ok, map} = Loggers.create_map(@create_attrs)
    map
  end

  defp create_map(_) do
    map = fixture(:map)
    %{map: map}
  end

  describe "Index" do
    setup [:create_map]

    test "lists all maps", %{conn: conn, map: map} do
      {:ok, _index_live, html} = live(conn, Routes.map_index_path(conn, :index))

      assert html =~ "Listing Maps"
      assert html =~ map.description
    end

    test "saves new map", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.map_index_path(conn, :index))

      assert index_live |> element("a", "New Map") |> render_click() =~
               "New Map"

      assert_patch(index_live, Routes.map_index_path(conn, :new))

      assert index_live
             |> form("#map-form", map: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#map-form", map: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.map_index_path(conn, :index))

      assert html =~ "Map created successfully"
      assert html =~ "some description"
    end

    test "updates map in listing", %{conn: conn, map: map} do
      {:ok, index_live, _html} = live(conn, Routes.map_index_path(conn, :index))

      assert index_live |> element("#map-#{map.id} a", "Edit") |> render_click() =~
               "Edit Map"

      assert_patch(index_live, Routes.map_index_path(conn, :edit, map))

      assert index_live
             |> form("#map-form", map: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#map-form", map: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.map_index_path(conn, :index))

      assert html =~ "Map updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes map in listing", %{conn: conn, map: map} do
      {:ok, index_live, _html} = live(conn, Routes.map_index_path(conn, :index))

      assert index_live |> element("#map-#{map.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#map-#{map.id}")
    end
  end

  describe "Show" do
    setup [:create_map]

    test "displays map", %{conn: conn, map: map} do
      {:ok, _show_live, html} = live(conn, Routes.map_show_path(conn, :show, map))

      assert html =~ "Show Map"
      assert html =~ map.description
    end

    test "updates map within modal", %{conn: conn, map: map} do
      {:ok, show_live, _html} = live(conn, Routes.map_show_path(conn, :show, map))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Map"

      assert_patch(show_live, Routes.map_show_path(conn, :edit, map))

      assert show_live
             |> form("#map-form", map: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#map-form", map: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.map_show_path(conn, :show, map))

      assert html =~ "Map updated successfully"
      assert html =~ "some updated description"
    end
  end
end
