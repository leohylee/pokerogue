#!/bin/bash
# SPDX-FileCopyrightText: 2025 Pagefault Games
# SPDX-License-Identifier: AGPL-3.0-only

# One-click script to run PokéRogue offline with Docker

echo "🎮 Starting PokéRogue in offline mode..."
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
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

echo "🐳 Building and starting Docker container..."
docker compose up --build

echo ""
echo "✅ PokéRogue is now running at http://localhost:8000"
echo "Press Ctrl+C to stop the application."
