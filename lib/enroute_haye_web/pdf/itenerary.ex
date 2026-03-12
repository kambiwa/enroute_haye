defmodule ItineraryPDF do
  @moduledoc """
  Generates a branded PDF itinerary by invoking the Python script
  `priv/scripts/itinerary_pdf.py` via System.cmd.

  The script reads a JSON payload from stdin and writes raw PDF bytes to stdout.
  """

  @script Path.join(:code.priv_dir(:enroute_haye), "scripts/itinerary_pdf.py")

  @doc """
  Generates the PDF from the given map of itinerary data.
  Returns `{:ok, binary}` or `{:error, reason}`.
  """
  def generate(data) when is_map(data) do
    json = Jason.encode!(stringify_keys(data))

    case System.cmd("python3", [@script], input: json, stderr_to_stdout: false) do
      {pdf_bytes, 0} when byte_size(pdf_bytes) > 0 ->
        {:ok, pdf_bytes}

      {output, exit_code} ->
        {:error, "PDF generation failed (exit #{exit_code}): #{output}"}
    end
  end

  # Ensure all map keys are strings for Python JSON compatibility
  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {k, v} ->
      key = if is_atom(k), do: Atom.to_string(k), else: k
      {key, stringify_keys(v)}
    end)
  end

  defp stringify_keys(list) when is_list(list), do: Enum.map(list, &stringify_keys/1)
  defp stringify_keys(other), do: other
end
