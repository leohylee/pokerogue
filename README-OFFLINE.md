# PokéRogue - Offline Setup Guide

This guide explains how to run PokéRogue completely offline with all assets (images, sounds, etc.) included.

## Repository Overview

**You only need the `pokerogue` repository for offline play.** Here's what each repository does:

| Repository | Required for Offline? | Purpose |
|------------|----------------------|---------|
| **pokerogue** | ✅ YES | Main game client (browser app) |
| **pokerogue-assets** | ✅ YES (submodule) | Images, sprites, audio, animations |
| **pokerogue-locales** | ✅ YES (submodule) | Translations (29 languages) |
| **rogueserver** | ❌ NO | Backend API for user accounts, cloud saves, daily challenges |

**Your current setup works 100% offline** because:
- `VITE_BYPASS_LOGIN=1` is enabled
- All saves go to browser localStorage
- All assets are bundled in the Docker image
- No server connection needed

## Prerequisites

- Docker Desktop installed and running
- All git submodules initialized (assets and locales)

## Quick Start (One-Click)

Run the startup script:

```bash
./start-offline.sh
```

This will:
1. Check if Docker is running
2. Initialize asset/locale submodules if needed
3. Build and start the Docker container
4. Serve the app at http://localhost:8000

## Manual Start

If you prefer to run commands manually:

```bash
# Start Docker Desktop first, then run:
docker compose up --build
```

Or run in detached mode (background):

```bash
docker compose up -d --build
```

## Access the Application

Once running, open your browser and navigate to:

**http://localhost:8000**

The application will run completely offline with all assets loaded locally.

## What's Included

The Docker setup includes:

- **All game assets** from the `assets/` submodule:
  - Images (Pokémon sprites, UI elements)
  - Audio (music, sound effects)
  - Battle animations
  - Fonts

- **All translations** from the `locales/` submodule:
  - 29 different language files

- **Complete source code** with dependencies pre-installed

## Stopping the Application

To stop the running container:

```bash
docker compose down
```

## Rebuilding

If you update the code or assets:

```bash
docker compose up --build
```

## Container Details

- **Image**: Node 22.14 Alpine
- **Port**: 8000 (host) → 8000 (container)
- **Mode**: Development (with hot reload)
- **User**: Non-root user (appuser)
- **Environment Variables**:
  - `VITE_BYPASS_LOGIN=1` - Skip login screen
  - `VITE_BYPASS_TUTORIAL=0` - Show tutorial
  - `NODE_ENV=development` - Development mode

## Troubleshooting

### Container won't start
- Ensure Docker Desktop is running
- Check if port 8000 is already in use: `lsof -i :8000`
- View container logs: `docker logs pokerogue-app`

### Assets not loading
- Verify submodules are initialized:
  ```bash
  git submodule update --init --recursive
  ```
- Rebuild the container: `docker compose up --build`

### Permission issues
- The container runs as a non-root user (appuser)
- Assets are mounted as read-only for security

## File Structure

```
pokerogue/
├── assets/              # Git submodule with all game assets
├── locales/            # Git submodule with translations
├── docker-compose.yml  # Docker composition configuration
├── Dockerfile          # Container build instructions
├── start-offline.sh    # One-click startup script
└── src/                # Game source code
```

## Notes

- The Docker image is ~6GB due to all the included assets
- First build may take several minutes
- Subsequent builds use cached layers and are much faster
- All assets are bundled in the image for true offline capability

## Adding Online Features (Optional)

If you want user accounts, cloud saves, and daily challenges, you'll need the **rogueserver** backend:

1. Clone the rogueserver repo (should be in parent directory: `../rogueserver`)
2. Use the full setup: `docker compose -f docker-compose-with-server.yml up`

This will start:
- PostgreSQL database (port 5432)
- Backend API server (port 8001)
- Frontend game client (port 8000)

The [docker-compose-with-server.yml](docker-compose-with-server.yml) file contains the full configuration.
