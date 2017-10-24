defmodule EHealth.MedicationRequests.SMSSender do
  @moduledoc false

  alias EHealth.API.OTPVerification

  def maybe_send_sms(mrr, person, template_fun) do
    is_otp = Enum.filter(person["authentication_methods"], fn method -> method["type"] == "OTP" end)
    if length(is_otp) > 0 do
      phone_number = is_otp |> Enum.at(0) |> Map.get("phone_number")
      {:ok, _} = OTPVerification.send_sms(phone_number, template_fun.(mrr))
    end
  end

  def sign_template(mrr) do
    Confex.fetch_env!(:ehealth, :medication_request)[:sign_template_sms]
    |> String.replace("<number>", mrr.number)
    |> String.replace("<verification_code>", mrr.verification_code)
  end

  def reject_template(mr) do
    Confex.fetch_env!(:ehealth, :medication_request)[:reject_template_sms]
    |> String.replace("<number>", mr.number)
    |> String.replace("<created_at>", mr.created_at)
  end
end
