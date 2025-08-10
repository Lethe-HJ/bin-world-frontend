#!/bin/bash

# Bin World Development Script
# This script starts all development services: frontend, backend, and Tauri

echo "🚀 Starting Bin World development environment..."

# Setup Rust compilation cache
export RUSTC_WRAPPER=sccache
export SCCACHE_DIR=$HOME/.cache/sccache
export SCCACHE_CACHE_SIZE="10G"

# Create sccache directory if it doesn't exist
mkdir -p $SCCACHE_DIR

# Check if sccache is available
if command -v sccache &> /dev/null; then
    echo "⚡ Rust 编译缓存已启用 (sccache)"
else
    echo "⚠️  建议安装 sccache 以加速 Rust 编译: cargo install sccache"
    unset RUSTC_WRAPPER
fi

# Function to cleanup background processes on exit
cleanup() {
    echo "🛑 Stopping all development services..."
    kill $(jobs -p) 2>/dev/null
    exit 0
}

# Set up trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Load bash profile to get nvm
if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
fi

# Check if nvm is installed
echo "🔍 Checking nvm installation..."
if ! command -v nvm &> /dev/null; then
    echo "❌ nvm is not installed. Please install nvm first:"
    echo "   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    exit 1
fi

# Check and set Node.js version for frontend/backend (22.14.0)
echo "🔍 Checking Node.js version for frontend/backend..."
CURRENT_NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_NODE_VERSION="22.14.0"

if [ "$CURRENT_NODE_VERSION" != "$REQUIRED_NODE_VERSION" ]; then
    echo "🔄 Switching to Node.js $REQUIRED_NODE_VERSION..."
    
    # Try to use the required version
    if ! nvm use $REQUIRED_NODE_VERSION 2>/dev/null; then
        echo "📦 Installing Node.js $REQUIRED_NODE_VERSION..."
        if ! nvm install $REQUIRED_NODE_VERSION; then
            echo "❌ Failed to install Node.js $REQUIRED_NODE_VERSION"
            exit 1
        fi
        nvm use $REQUIRED_NODE_VERSION
    fi
fi

echo "✅ Node.js version $(node --version) is set for frontend/backend"

# Check if node_modules exists in frontend
echo "🔍 Checking frontend dependencies..."
if [ ! -d "frontend/node_modules" ]; then
    echo "❌ Frontend node_modules not found. Installing dependencies..."
    cd frontend
    if ! yarn install; then
        echo "❌ Failed to install frontend dependencies"
        exit 1
    fi
    cd ..
else
    echo "✅ Frontend dependencies found"
fi

# Check if node_modules exists in root
echo "🔍 Checking root dependencies..."
if [ ! -d "node_modules" ]; then
    echo "❌ Root node_modules not found. Installing dependencies..."
    if ! yarn install; then
        echo "❌ Failed to install root dependencies"
        exit 1
    fi
else
    echo "✅ Root dependencies found"
fi

# Check if conda is installed
echo "🔍 Checking conda installation..."
if ! command -v conda &> /dev/null; then
    echo "❌ conda is not installed. Please install conda first."
    exit 1
fi

# Check Python version
echo "🔍 Checking Python version..."
CURRENT_PYTHON_VERSION=$(python --version 2>&1 | cut -d' ' -f2)
REQUIRED_PYTHON_VERSION="3.13.5"

if [ "$CURRENT_PYTHON_VERSION" != "$REQUIRED_PYTHON_VERSION" ]; then
    echo "🔄 Installing Python $REQUIRED_PYTHON_VERSION..."
    if ! conda install python=$REQUIRED_PYTHON_VERSION -y; then
        echo "❌ Failed to install Python $REQUIRED_PYTHON_VERSION"
        exit 1
    fi
fi

echo "✅ Python version $(python --version) is set"

# Check Python virtual environment
echo "🔍 Checking Python virtual environment..."
if [ ! -d "backend/venv" ]; then
    echo "❌ Python virtual environment not found. Creating venv..."
    cd backend
    if ! python -m venv venv; then
        echo "❌ Failed to create Python virtual environment"
        exit 1
    fi
    cd ..
fi

# Activate virtual environment and check dependencies
echo "🔍 Checking Python dependencies..."
cd backend
source venv/bin/activate

# Check if requirements are installed
if ! python -c "import robyn" 2>/dev/null; then
    echo "❌ Python dependencies not found. Installing requirements..."
    if ! pip install -r requirements.txt; then
        echo "❌ Failed to install Python dependencies"
        exit 1
    fi
else
    echo "✅ Python dependencies found"
fi

cd ..

# Switch to Node.js 20 for Tauri (desktop)
echo "🔍 Switching to Node.js 20 for Tauri..."
if ! nvm use 20 2>/dev/null; then
    echo "📦 Installing Node.js 20..."
    if ! nvm install 20; then
        echo "❌ Failed to install Node.js 20"
        exit 1
    fi
    nvm use 20
fi

echo "✅ Node.js version $(node --version) is set for Tauri"

# Check Tauri dependencies
echo "🔍 Checking Tauri dependencies..."
if ! command -v tauri &> /dev/null; then
    echo "❌ Tauri CLI not found. Installing..."
    if ! npm install -g @tauri-apps/cli; then
        echo "❌ Failed to install Tauri CLI"
        exit 1
    fi
fi

echo "✅ All prerequisites checked successfully!"

# Switch back to Node.js 22.14.0 for frontend/backend
nvm use $REQUIRED_NODE_VERSION

# Start frontend
echo "📱 Starting frontend (Vue.js)..."
cd frontend && yarn dev &
FRONTEND_PID=$!

# Start backend
echo "🐍 Starting backend (Robyn)..."
cd backend && source venv/bin/activate && python app.py &
BACKEND_PID=$!

# Wait for frontend to be ready
echo "⏳ Waiting for frontend to be ready..."
# Use a simple loop instead of wait-on
while ! curl -s http://localhost:5173 > /dev/null; do
    sleep 1
done

# Switch to Node.js 20 for Tauri
nvm use 20

# Start Tauri
echo "🖥️  Starting Tauri desktop application..."
tauri dev &
TAURI_PID=$!

echo "✅ All services started!"
echo "   Frontend: http://localhost:5173"
echo "   Backend:  http://localhost:8080"
echo "   Tauri:    Desktop application"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for all background processes
wait
