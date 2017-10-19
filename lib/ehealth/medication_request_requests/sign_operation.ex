defmodule EHealth.MedicationRequestRequest.SignOperation do
  @moduledoc false
  import Ecto.Changeset
  import EHealth.MedicationRequestRequest.OperationHelpers

  alias EHealth.API.MediaStorage
  alias EHealth.MedicationRequestRequest.Operation
  alias EHealth.MedicationRequestRequest.Validations
  alias EHealth.API.OPS

  def sign(mrr, params, client_id) do
    %Ecto.Changeset{}
    |> Operation.new
    |> validate_data(params, &decode_sign_content/2, key: :decoded_content)
    |> validate_sign_content(mrr)
    |> upload_sign_content(params, mrr)
    |> create_medication_request()
    |> validate_ops_resp(mrr)
  end

  def decode_sign_content(_operation, params) do
     {:ok, %{"data" => %{"content" => content}}} = Validations.decode_sign_content(params)
     {:ok, content}
  end

  def validate_sign_content(operation, mrr) do
    Validations.validate_sign_content(mrr, operation.data.decoded_content)
  end

  def upload_sign_content({:error, error}, _, _), do: {:error, error}
  def upload_sign_content({:ok, content}, params, mrr) do
    params
    |> Map.fetch!("signed_medication_request_request")
    |> MediaStorage.store_signed_content(:medication_request_bucket, Map.fetch!(mrr, :medication_request_id), [])
    |> validate_api_response(mrr)
  end

  defp validate_api_response({:ok, _}, db_data), do: {:ok, db_data}
  defp validate_api_response(error, _db_data), do: error

  def create_medication_request({:error, error}), do: {:error, error}
  def create_medication_request({:ok, mrr}) do
    params =
      mrr.data
      |> Map.put(:id, mrr.medication_request_id)
      |> Map.put(:medication_request_requests_id, mrr.id)
      |> Map.put(:request_number, mrr.number)
      |> Map.put(:verification_code, mrr.verification_code)
    OPS.create_medication_request(%{medication_request: params})
  end

  def validate_ops_resp({:error, error}, _), do: {:error, error}
  def validate_ops_resp({:ok, %{"data" => ops_resp}}, mrr) do
    if ops_resp["id"] == mrr.medication_request_id do
      {:ok, mrr}
    else
       {:error, %{"type" => "internal_error"}}
    end
  end
  def validate_ops_resp(_), do: {:error, %{"type" => "internal_error"}}
end
