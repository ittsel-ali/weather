import React from "react";

const WeatherForecast = ({ forecast }) => {
  const { current_weather, daily_forecast } = forecast;

  const getWeatherIcon = (condition) => {
    switch (condition) {
      case "Clear":
        return "☀️";
      case "Partly Cloudy":
        return "⛅";
      case "Fog":
        return "🌫️";
      case "Drizzle":
        return "🌦️";
      case "Rain":
        return "🌧️";
      case "Snow":
        return "❄️";
      case "Thunderstorm":
        return "⛈️";
      case "Thunderstorm with Hail":
        return "🌩️";
      default:
        return "🌍";
    }
  };

  const getDayName = (dateString) => {
    const date = new Date(dateString);
    return dateString;
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-6 ">
      <div className="max-w-5xl w-full">
        <h2 className="text-4xl font-bold text-white mb-8 text-center">
          🌤️ Weather Forecast
        </h2>
        <div className="bg-gray-800 bg-opacity-30 backdrop-blur-md rounded-xl shadow-lg p-6 mb-8">
          <h3 className="text-2xl font-semibold text-white mb-4">
            Current Weather
          </h3>
          <div className="flex items-center justify-between">
            <div className="text-6xl">{getWeatherIcon(current_weather.condition)}</div>
            <div className="text-white">
              <p className="text-lg">
                Temperature: <span className="font-bold">{current_weather.temperature}°C</span>
              </p>
              <p className="text-lg">Condition: {current_weather.condition}</p>
              <p className="text-lg">Wind Speed: {current_weather.wind_speed} km/h</p>
            </div>
          </div>
        </div>
        <h3 className="text-2xl font-semibold text-white mb-6">Extended Forecast</h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          {daily_forecast.map((day, index) => (
            <div
              key={index}
              className="bg-gray-800 bg-opacity-30 backdrop-blur-md rounded-xl shadow-lg p-6 flex flex-col items-center text-center"
            >
              <div className="text-5xl mb-4">{getWeatherIcon(day.condition)}</div>
              <p className="text-lg font-bold text-white">{getDayName(day.date)}</p>
              <p className="text-blue-400">Max: {day.max_temperature}°C</p>
              <p className="text-blue-300">Min: {day.min_temperature}°C</p>
              <p className="text-white">Condition: {day.condition}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default WeatherForecast;
