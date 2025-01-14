# Weather Forecast

This project is a **Weather Forecast Application** that provides real-time weather updates and extended forecasts for any location. It also includes an address lookup feature for finding locations based on partial address inputs.
#### API DOC: https://github.com/ittsel-ali/weather/blob/main/docs/api_readme.md
#### Demo: [Watch the Demo](https://www.dropbox.com/scl/fi/ehqea5t5rvzaqizfhqtbw/demo.mp4?rlkey=tacmr118hrd5gb491e1bex1gq&st=xo2cb808&dl=0)


---

## Features

### 1. **Weather Forecast**
- Displays current weather conditions:
  - Temperature
  - Wind speed
  - Weather condition (e.g., Clear, Rainy)
- Provides extended forecasts for 7 days.

### 2. **Address Lookup**
- Search for locations using partial or full address inputs.
- Returns suggestions with full address and geographic coordinates.

---

## Installation

### Prerequisites
- **Ruby** (= 3.3.0)
- **Rails** (= 7.1.5, API-only mode)
- **Node.js** (>= 22.x)
- **Vite** (for React integration)

### Steps
1. Clone the repository:
   ```bash
   git clone git@github.com:ittsel-ali/weather.git
   cd weather

2. Install backend dependencies:
   ```bash
    bundle install

3. Install frontend dependencies:
   ```bash
   cd app/ui
   npm install

4. Start the Vite server for the React frontend:
   ```bash
   cd app/ui
   npm run dev

5. Open the application in your browser at:
   ```bash
   http://localhost:3000

## Environment Configuration

Use `.env-example` files for setup:

- **Rails API**: Copy `.env-example` in the root folder to `.env` and update values.
- **React UI**: Copy `.env-example` in `app/ui` to `.env` and update values.


## Continuous Integration (CI)

This project includes **GitHub Actions** for automated Continuous Integration checks:

### CI Workflows
1. **Linting**:
   - Uses **RuboCop** to enforce Ruby style guides and best practices.
   - Automatically runs on every push and pull request to the `main` branch.

2. **Testing**:
   - Executes all **Rails tests** in the test suite to ensure functionality.
