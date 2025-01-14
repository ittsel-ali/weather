// app/ui/utils/apiService.js

import axios from "axios";

const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL, // Use environment variable for base URL
});

/**
 * Centralized API service with error handling.
 */
const apiService = {
  get: async (url, params = {}) => {
    try {
      const response = await apiClient.get(url, { params });
      return response.data.data; // Assuming API responses have a `data` field
    } catch (error) {
      handleApiError(error);
      throw error;
    }
  },
};

/**
 * Handles API errors by logging them.
 * @param {Error} error - The error object from the API call.
 */
const handleApiError = (error) => {
  if (error.response) {
    console.error(`API Error: ${error.response.status} - ${error.response.data?.message || error.message}`);
  } else if (error.request) {
    console.error("API Error: No response received from server.");
  } else {
    console.error(`API Error: ${error.message}`);
  }
};

export default apiService;
