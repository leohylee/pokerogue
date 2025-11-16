#!/bin/bash
# SPDX-FileCopyrightText: 2025 Pagefault Games
# SPDX-License-Identifier: AGPL-3.0-only

# One-click script to run PokéRogue full-stack (DB + Server + Client)

echo "🎮 Starting PokéRogue Full-Stack (offline-capable)..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Check if rogueserver exists
if [ ! -d "../rogueserver" ]; then
    echo "❌ rogueserver not found at ../rogueserver"
    echo "Please clone it: git clone https://github.com/pagefaultgames/rogueserver ../rogueserver"
    exit 1
fi

# Check if assets submodule is initialized
if [ ! -f "assets/manifest.webmanifest" ]; then
    echo "📦 Initializing assets submodule..."
    git submodule update --init --recursive assets
fi

# Check if locales submodule is initialized
if [ ! -d "locales/en" ]; then
    echo "🌍 Initializing locales submodule..."
    git submodule update --init --recursive locales
fi

echo "🐳 Building and starting Docker containers..."
echo "   - Database (MariaDB 11)"
echo "   - Backend Server (Go)"
echo "   - Frontend Client (Node.js)"
echo ""
echo "⏳ First build will take 5-10 minutes (downloading images + compiling)..."
echo ""

docker compose -f docker-compose-fullstack.yml up --build

echo ""
echo "✅ PokéRogue full-stack is now running!"
echo ""
echo "   🎮 Game:     http://localhost:8000"
echo "   🔌 API:      http://localhost:8001"
echo "   💾 Database: localhost:3306"
echo ""
echo "📝 Create an account at http://localhost:8000 (login required)"
echo "Press Ctrl+C to stop all services."
