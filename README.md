# Bin World - Tauri Desktop Application

This is a Tauri-based desktop application that provides a desktop shell for web applications.

## Project Architecture

This project follows a modular architecture with the following components:

- **Desktop Application**: Tauri-based desktop shell (this directory)
- **Frontend**: Vue.js web application (in `frontend/` directory)
- **Backend**: Python/Rust web backend (planned)

## Development Setup

### Prerequisites

- [Node.js](https://nodejs.org/)
- [Rust](https://rustup.rs/)
- [Tauri CLI](https://tauri.app/v1/guides/getting-started/setup/)

### Recommended IDE Setup

- [VS Code](https://code.visualstudio.com/) + [Tauri](https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode) + [rust-analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)

### Development Workflow

The desktop application loads the frontend from a web URL. You can start both the frontend and desktop application with a single command:

```bash
# Start both frontend and Tauri desktop application
yarn dev
```

This command will:
1. Start the frontend development server on http://localhost:5173
2. Wait for the frontend to be ready
3. Launch the Tauri desktop application

### Alternative Commands

```bash
# Start only the Tauri desktop application (requires frontend to be running)
yarn tauri:dev

# Build frontend (optional, for production deployment)
cd frontend
yarn build

# Build Tauri application
yarn tauri:build
```

## Project Structure

- `src-tauri/`: Tauri backend (Rust)
- `frontend/`: Vue.js frontend application (runs on http://localhost:5173)
- `docs/`: Project documentation

## Configuration

The Tauri application is configured to load the frontend from `http://localhost:5173` by default. You can modify this URL in `src-tauri/tauri.conf.json` if needed.


