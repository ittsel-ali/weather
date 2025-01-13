import React, { useState } from "react";
import apiService from "../utils/apiService";
import WeatherForecast from "./WeatherForecast";

const AddressSearchBar = () => {
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [forecast, setForecast] = useState(null);

  const fetchSuggestions = async (searchQuery) => {
    try {
      const addresses = await apiService.get("/geocoder/address_lookup", { query: searchQuery });
      setSuggestions(addresses);
    } catch (error) {
      console.error("Failed to fetch address suggestions.");
    }
  };

  const fetchForecast = async (lat, lon) => {
    try {
      console.log(lat, lon);
      const weatherData = await apiService.get("/weather/forecast", { lat, lon });
      setForecast(weatherData);
    } catch (error) {
      console.error("Failed to fetch weather forecast.");
    }
  };

  const handleInputChange = (e) => {
    const value = e.target.value;
    setQuery(value);
    if (value) fetchSuggestions(value);
    else setSuggestions([]);
  };

  const handleSuggestionClick = (lat, lon) => {
    setSuggestions([]);
    setQuery("");
    fetchForecast(lat, lon);
  };

  return (
    <div className="p-4 bg-gradient-to-br from-red-400 to-gray-900 rounded-lg">
      <div className="relative">
        <input
          type="text"
          className="w-full px-4 py-2 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring focus:ring-blue-300"
          placeholder="Search for an address..."
          value={query}
          onChange={handleInputChange}
        />
        {suggestions.length > 0 && (
          <ul className="absolute w-full bg-white border border-gray-300 rounded-lg shadow-lg mt-2 max-h-60 overflow-auto">
            {suggestions.map((suggestion, index) => (
              <li
                key={index}
                className="px-4 py-2 hover:bg-blue-100 cursor-pointer"
                onClick={() => handleSuggestionClick(suggestion.lat, suggestion.lon)}
              >
                {suggestion.full_address}
              </li>
            ))}
          </ul>
        )}
      </div>
      {forecast && <WeatherForecast forecast={forecast} />}
    </div>
  );
};

export default AddressSearchBar;
