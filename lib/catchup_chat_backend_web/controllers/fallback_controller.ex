defmodule CatchupChatBackendWeb.FallbackController do
  use CatchupChatBackendWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: CatchupChatBackendWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end
end
