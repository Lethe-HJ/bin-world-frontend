# Scripts Directory

This directory contains development and utility scripts for the Bin World project.

## Available Scripts

### `dev.sh`
Development startup script that launches all services:
- Frontend (Vue.js) on http://localhost:5173
- Backend (Robyn) on http://localhost:8080
- Tauri desktop application

**Usage:**
```bash
./scripts/dev.sh
# or
yarn dev
```

**Features:**
- Automatic service startup and management
- Graceful shutdown with Ctrl+C
- Clear status feedback
- Process cleanup on exit

**Prerequisites Check:**
The script automatically checks and sets up:

**Node.js Management (via nvm):**
- ✅ nvm installation check
- ✅ Node.js 22.14.0 for frontend/backend (installs if missing)
- ✅ Node.js 20 for Tauri desktop (installs if missing)
- ✅ Automatic version switching between services

**Python Management (via conda):**
- ✅ conda installation check
- ✅ Python 3.13.5 (installs if missing)
- ✅ Python virtual environment (creates if missing)
- ✅ Python dependencies (installs if missing)

**Dependencies:**
- ✅ Frontend dependencies (installs if missing)
- ✅ Root dependencies (installs if missing)
- ✅ Tauri CLI (installs if missing)

**Error Handling:**
- Stops execution if any prerequisite check fails
- Provides clear error messages for each failure
- Automatically installs missing dependencies when possible

**Version Management:**
- Uses Node.js 22.14.0 for frontend and backend development
- Switches to Node.js 20 for Tauri desktop application
- Automatically manages Python 3.13.5 via conda

## Adding New Scripts

When adding new scripts to this directory:
1. Make them executable: `chmod +x scripts/your-script.sh`
2. Update this README with usage instructions
3. Consider adding npm scripts in `package.json` for easy access
