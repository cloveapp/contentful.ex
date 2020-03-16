defmodule Contentful.Delivery.Spaces do
  @moduledoc """
  Spaces provides function related to the reading of spaces 
  through the Contentful Delivery API
  """

  alias Contentful.{Delivery, MetaData, Space}

  @doc """
  fetch_one() will retrieve one space by it's space id

  ## Examples

      # space you have access to, token will be read from config/config.exs
      iex> {:ok, space} = Contentful.Delivery.Spaces.fetch_one("space_id")
      {:ok, %Contentful.Space{name: "a space name", meta_data: %{id: "space_id"}}}

      # space that does not exist
      iex> {:error, :not_found, original_message: _message} 
        = Contentful.Delivery.Spaces.fetch_one("non_existing_space", "<your_api_key>")

      # no access
      iex> {:error, :unauthorized, original_message: _message} 
        = Contentful.Delivery.Spaces.fetch_one("non_existing_space", "<your_api_key>")
  """
  @spec fetch_one(String.t(), String.t()) ::
          {:ok, Space.t()}
          | {:error, atom(), list(keyword())}
          | {:error, :unknown}
  def fetch_one(id, api_key \\ nil) do
    id
    |> build_request(api_key)
    |> Delivery.send_request()
    |> Delivery.parse_response(&build_space/1)
  end

  defp build_request(space_id, api_key) do
    url = space_id |> Delivery.url()
    {url, api_key |> Delivery.request_headers()}
  end

  defp build_space(%{
         "locales" => _locales,
         "name" => name,
         "sys" => %{"id" => id, "type" => "Space"}
       }) do
    {:ok, %Space{name: name, meta_data: %MetaData{id: id}}}
  end
end
