import React from "react";
import ReactDOM from "react-dom/client"; // Import the new API
import App from "./App";

// Create the root container
const root = ReactDOM.createRoot(document.getElementById("react-root"));

// Render the App component
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
