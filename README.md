# Bin World - Tauri Desktop Application

This is a Tauri-based desktop application that provides a desktop shell for web applications.

## Project Architecture

This project follows a modular architecture with the following components:

- **Desktop Application**: Tauri-based desktop shell (this directory)
- **Frontend**: Vue.js web application (in `frontend/` directory)
- **Backend**: Python web backend using Robyn (in `backend/` directory)

## Development Setup

### Prerequisites

- [Node.js](https://nodejs.org/)
- [Rust](https://rustup.rs/)
- [Tauri CLI](https://tauri.app/v1/guides/getting-started/setup/)
- [Python 3.13+](https://www.python.org/)
- [Robyn](https://robyn.tech/) (for backend development)

### Recommended IDE Setup

- [VS Code](https://code.visualstudio.com/) + [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)

### Development Workflow

The desktop application loads the frontend from a web URL. You can start all services with a single command:

```bash
# Start all development services
yarn dev
# or
./scripts/dev.sh
```

This command will:
1. Start the frontend development server on http://localhost:5173
2. Start the backend Robyn server on http://localhost:8080
3. Wait for the frontend to be ready
4. Launch the Tauri desktop application

### Alternative Commands

```bash
# Start only the Tauri desktop application (requires frontend to be running)
yarn tauri:dev

# Start only the backend Robyn server
cd backend && python app.py

# Build frontend (optional, for production deployment)
cd frontend
yarn build

# Build Tauri application
yarn tauri:build
```

## Project Structure

- `src-tauri/`: Tauri backend (Rust)
- `frontend/`: Vue.js frontend application (runs on http://localhost:5173)
- `backend/`: Python web backend using Robyn (runs on http://localhost:8080)
- `docs/`: Project documentation
- `scripts/`: Development and utility scripts
  - `dev.sh`: Development startup script

## Configuration

The Tauri application is configured to load the frontend from `http://localhost:5173` by default. You can modify this URL in `src-tauri/tauri.conf.json` if needed.


