defmodule EHealth.Employee.EmployeeCreator do
  @moduledoc """
  Creates new employee from valid employee request
  """

  import EHealth.Utils.Connection, only: [get_consumer_id: 1]
  import Ecto.Query

  alias Scrivener.Page
  alias EHealth.Employee.Request
  alias EHealth.PRM.Employees
  alias EHealth.PRM.Parties.Schema, as: Party
  alias EHealth.PRM.Employees.Schema, as: Employee
  alias EHealth.PRM.PartyUsers.Schema, as: PartyUser
  alias EHealth.PRM.Parties
  alias EHealth.PRM.PartyUsers
  alias EHealth.Employee.EmployeeUpdater
  alias EHealth.PRMRepo

  require Logger

  @type_owner Employee.type(:owner)
  @type_pharmacy_owner Employee.type(:pharmacy_owner)
  @status_approved Employee.status(:approved)

  def create(%Request{data: data} = employee_request, req_headers) do
    party = Map.fetch!(data, "party")
    search_params = %{tax_id: party["tax_id"], birth_date: party["birth_date"]}
    user_id = get_consumer_id(req_headers)

    with %Page{} = paging <- Parties.list_parties(search_params),
         :ok <- check_party_user(user_id, paging.entries),
         {:ok, party} <- create_or_update_party(paging.entries, party, req_headers)
    do
      result = PRMRepo.transaction(fn ->
        deactivate_employee_owners(
          employee_request.data["employee_type"],
          employee_request.data["legal_entity_id"],
          req_headers
        )
        create_employee(party, employee_request, req_headers)
      end)
      elem(result, 1)
    end
  end

  @doc """
  Created new party
  """
  def create_or_update_party([], data, req_headers) do
    with data <- put_inserted_by(data, req_headers),
         consumer_id = get_consumer_id(req_headers),
         {:ok, party} <- Parties.create_party(data, consumer_id)
    do
      create_party_user(party, req_headers)
    end
  end

  @doc """
  Updates party
  """
  def create_or_update_party([%Party{} = party], data, req_headers) do
    consumer_id = get_consumer_id(req_headers)

    with {:ok, party} <- Parties.update_party(party, data, consumer_id) do
      create_party_user(party, req_headers)
    end
  end

  def create_party_user(%Party{id: id, users: users} = party, headers) do
    user_ids = Enum.map(users, &Map.get(&1, :user_id))
    consumer_id = get_consumer_id(headers)

    case Enum.member?(user_ids, consumer_id) do
      true ->
        {:ok, party}
      false ->
        case PartyUsers.create_party_user(id, consumer_id) do
          {:ok, _} -> {:ok, party}
          {:error, _} = err -> err
        end
    end
  end

  def create_employee(%Party{id: id}, %Request{data: employee_request}, req_headers) do
    data = %{
      "status" => @status_approved,
      "is_active" => true,
      "party_id" => id,
      "legal_entity_id" => employee_request["legal_entity_id"],
    }

    data
    |> Map.merge(employee_request)
    |> put_inserted_by(req_headers)
    |> Employees.create_employee(get_consumer_id(req_headers))
  end
  def create_employee(err, _, _), do: err

  def deactivate_employee_owners(@type_owner = type, legal_entity_id, req_headers) do
    do_deactivate_employee_owner(type, legal_entity_id, req_headers)
  end
  def deactivate_employee_owners(@type_pharmacy_owner = type, legal_entity_id, req_headers) do
    do_deactivate_employee_owner(type, legal_entity_id, req_headers)
  end
  def deactivate_employee_owners(_, _, _req_headers), do: :ok

  defp do_deactivate_employee_owner(type, legal_entity_id, req_headers) do
    employee =
      Employee
      |> where([e], e.is_active)
      |> where([e], e.employee_type == ^type)
      |> where([e], e.legal_entity_id == ^legal_entity_id)
      |> PRMRepo.one
    deactivate_employee(employee, req_headers)
  end

  def deactivate_employee(%Employee{} = employee, headers) do
    params = %{
      "updated_by" => get_consumer_id(headers),
      "is_active" => false,
    }

    with :ok <- EmployeeUpdater.revoke_user_auth_data(employee, headers) do
      Employees.update_employee(employee, params, get_consumer_id(headers))
    end
  end
  def deactivate_employee(employee, _), do: {:ok, employee}

  def put_inserted_by(data, req_headers) do
    map = %{
      "inserted_by" => get_consumer_id(req_headers),
      "updated_by" => get_consumer_id(req_headers),
    }
    Map.merge(data, map)
  end

  defp check_party_user(user_id, []) do
    with nil <- PartyUsers.get_party_users_by_user_id(user_id) do
      :ok
    else
      _ -> {:error, {:conflict, "Email is already used by another person"}}
    end
  end
  defp check_party_user(user_id, [%Party{id: party_id}]) do
    with nil <- PartyUsers.get_party_users_by_user_id(user_id) do
      :ok
    else
      %PartyUser{party: %Party{id: id}} when id == party_id -> :ok
      _ -> {:error, {:conflict, "Email is already used by another person"}}
    end
  end
end
