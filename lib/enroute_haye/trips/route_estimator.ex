defmodule EnrouteHaye.Trips.RouteEstimator do
  @moduledoc "Provides straight-line distance only when both site coordinates exist."

  def between(%{latitude: lat1, longitude: lon1}, %{latitude: lat2, longitude: lon2})
      when is_number(lat1) and is_number(lon1) and is_number(lat2) and is_number(lon2) do
    radians = :math.pi() / 180
    lat1 = lat1 * radians
    lat2 = lat2 * radians
    delta_lat = (lat2 - lat1)
    delta_lon = (lon2 - lon1) * radians

    haversine =
      :math.sin(delta_lat / 2) ** 2 +
        :math.cos(lat1) * :math.cos(lat2) * :math.sin(delta_lon / 2) ** 2

    %{direct_distance_km: Float.round(6371.0 * 2 * :math.asin(:math.sqrt(haversine)), 1), travel_time: nil}
  end

  def between(_from, _to), do: %{direct_distance_km: nil, travel_time: nil}
end
