# PokéRogue - Full-Stack Offline Setup

This guide explains how to run the complete PokéRogue stack with backend server, database, and authentication - all **offline-capable** and ready for cloud deployment.

## What's Included

This full-stack setup provides:

✅ **MariaDB Database** - Stores user accounts, save data, achievements
✅ **Backend API Server (Go)** - Handles authentication, save synchronization
✅ **Frontend Game Client** - The browser-based game
✅ **All Assets** - Images, audio, animations bundled offline
✅ **Real User Accounts** - Create accounts, log in, save to database
✅ **Cloud-Ready** - Same configuration works locally and in cloud

## Architecture

```
┌─────────────────────────────────────────┐
│         Browser (localhost:8000)         │
│          PokéRogue Game Client           │
└────────────┬────────────────────────────┘
             │ HTTP API calls
             ▼
┌─────────────────────────────────────────┐
│    Backend Server (localhost:8001)       │
│         Go API (rogueserver)             │
└────────────┬────────────────────────────┘
             │ SQL queries
             ▼
┌─────────────────────────────────────────┐
│     Database (localhost:3306)            │
│    MariaDB 11 (pokeroguedb)              │
└─────────────────────────────────────────┘
```

## Quick Start

### Option 1: One Command

```bash
docker compose -f docker-compose-fullstack.yml up -d --build
```

### Option 2: Watch the Build Process

```bash
docker compose -f docker-compose-fullstack.yml up --build
```

This will:
1. Download MariaDB 11 image
2. Build Go backend server from `../rogueserver`
3. Build Node.js frontend client
4. Start all three containers
5. Initialize the database

**First build takes 5-10 minutes** due to:
- Downloading base images (Golang, Node, MariaDB)
- Compiling Go server
- Installing npm dependencies
- Bundling 6GB of game assets

## Access the Application

Once running:

- **Game**: http://localhost:8000
- **API**: http://localhost:8001
- **Database**: localhost:3306 (user: `pokerogue`, pass: `pokerogue`)

## Creating an Account

Unlike the simple offline mode, this setup requires **real user registration**:

1. Open http://localhost:8000
2. Click "Register" (not bypassed)
3. Create a username and password
4. Your account is saved to the local database
5. Save files sync to the database (not localStorage)

## Services

### Database (MariaDB 11)
- **Container**: `pokerogue-db`
- **Port**: 3306
- **Database**: `pokeroguedb`
- **User**: `pokerogue` / `pokerogue`
- **Root Password**: `admin`
- **Data**: Persisted in Docker volume `database_data`

### Backend Server (Go)
- **Container**: `pokerogue-server`
- **Port**: 8001
- **Source**: `../rogueserver`
- **Environment**: Debug mode enabled
- **Features**: User auth, save data API, daily challenges

### Frontend Client (Node/Vite)
- **Container**: `pokerogue-client`
- **Port**: 8000
- **Source**: Current directory
- **Mode**: Development with hot reload
- **Login**: **Required** (VITE_BYPASS_LOGIN=0)

## Managing the Stack

### Start All Services
```bash
docker compose -f docker-compose-fullstack.yml up -d
```

### Stop All Services
```bash
docker compose -f docker-compose-fullstack.yml down
```

### View Logs
```bash
# All services
docker compose -f docker-compose-fullstack.yml logs -f

# Specific service
docker logs pokerogue-server -f
docker logs pokerogue-client -f
docker logs pokerogue-db -f
```

### Check Status
```bash
docker compose -f docker-compose-fullstack.yml ps
```

### Restart a Service
```bash
docker compose -f docker-compose-fullstack.yml restart server
```

## Database Management

### Connect to Database
```bash
docker exec -it pokerogue-db mariadb -u pokerogue -ppokerogue pokeroguedb
```

### Backup Database
```bash
docker exec pokerogue-db mariadb-dump -u pokerogue -ppokerogue pokeroguedb > backup.sql
```

### Restore Database
```bash
docker exec -i pokerogue-db mariadb -u pokerogue -ppokerogue pokeroguedb < backup.sql
```

### Reset Database
```bash
docker compose -f docker-compose-fullstack.yml down -v
docker compose -f docker-compose-fullstack.yml up -d
```

## Differences from Simple Offline Mode

| Feature | Simple Offline | Full-Stack |
|---------|---------------|------------|
| User Accounts | Guest only | Real registration |
| Save Location | Browser localStorage | MariaDB database |
| Login Required | No (bypassed) | Yes (real auth) |
| Cloud Sync | No | Ready for cloud |
| Services | 1 (client only) | 3 (db + server + client) |
| Port 8001 | Not used | API server |
| Port 3306 | Not used | Database |

## Cloud Deployment Ready

This setup is **identical** to what you'd run in production. To deploy to cloud:

1. **Update environment variables**:
   ```yaml
   - VITE_SERVER_URL=https://your-api-domain.com
   - gameurl=https://your-game-domain.com
   - callbackurl=https://your-api-domain.com
   ```

2. **Add external database**:
   - Point `dbaddr` to your cloud database
   - Update `dbuser`, `dbpass`, `dbname`

3. **Enable OAuth** (optional):
   - Set real Discord/Google client IDs
   - Configure OAuth callbacks

4. **Add SSL/TLS**:
   - Use nginx/Caddy reverse proxy
   - Configure SSL certificates

5. **Use production builds**:
   - Change `NODE_ENV=production`
   - Disable debug mode: `debug: "false"`

## Troubleshooting

### Database won't start
```bash
# Check logs
docker logs pokerogue-db

# Recreate database volume
docker compose -f docker-compose-fullstack.yml down -v
docker compose -f docker-compose-fullstack.yml up -d
```

### Server can't connect to database
```bash
# Wait for database healthcheck
docker compose -f docker-compose-fullstack.yml ps

# Should show "healthy" for database
```

### Client can't reach API
```bash
# Check if server is running
docker logs pokerogue-server

# Verify network
docker network inspect pokerogue_pokerogue_network
```

### Login not working
- Ensure `VITE_BYPASS_LOGIN=0` (not 1)
- Check browser console for API errors
- Verify server logs: `docker logs pokerogue-server -f`

## Development Workflow

### Make Code Changes

**Frontend** (pokerogue):
```bash
# Changes auto-reload via Vite
# Edit src/ files, refresh browser
```

**Backend** (rogueserver):
```bash
# Rebuild server container
docker compose -f docker-compose-fullstack.yml up -d --build server
```

### Access Database Shell
```bash
docker exec -it pokerogue-db mariadb -u pokerogue -ppokerogue
```

### Test API Endpoints
```bash
# Health check
curl http://localhost:8001/

# Get game stats (example)
curl http://localhost:8001/game/titlestats
```

## File Structure

```
pokerogue/
├── docker-compose-fullstack.yml     # This full-stack setup
├── docker-compose.yml               # Simple offline-only setup
├── Dockerfile                        # Client build
├── assets/                           # Game assets (submodule)
├── locales/                          # Translations (submodule)
└── src/                              # Game source code

../rogueserver/                       # Backend API (Go)
├── Dockerfile                        # Server build
├── api/                              # API handlers
├── db/                               # Database models
└── rogueserver.go                    # Main server file
```

## Performance

- **Database**: ~50MB RAM, instant queries
- **Server**: ~20MB RAM (Go is efficient!)
- **Client**: ~500MB RAM (Node + assets)
- **Total**: ~600MB RAM for full stack

## Security Notes

This setup uses **default credentials** for local development:
- Database: `pokerogue` / `pokerogue`
- Root password: `admin`

**Before cloud deployment**:
- Change all passwords
- Use environment variable secrets
- Enable SSL/TLS
- Configure firewall rules
- Use strong root password
- Restrict database access

## Why This Setup is Offline-Capable

Even though this includes a backend server and database:

✅ **All services run locally** - No external APIs
✅ **No internet required** - Everything in Docker
✅ **Data stays local** - Database volume on disk
✅ **Assets bundled** - 6GB in client container
✅ **Self-contained** - One command to start

You can disconnect from internet and it will still work!

## Next Steps

- Switch between setups with different compose files
- Export your save data from the database
- Customize the frontend without rebuilding
- Add new API endpoints to the backend
- Deploy to cloud when ready
