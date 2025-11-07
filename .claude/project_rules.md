# BibleAI Project Rules

## Server Management Rules

### 1. Always Use Shell Scripts
- **ALWAYS** use `./server.sh` for server management (start/stop/restart)
- **NEVER** manually kill processes with `kill -9` or similar commands
- **NEVER** start the server directly with `go run` - use the script

### 2. Check Server Status First
- **BEFORE** any server operation, check if server is running:
  ```bash
  ./server.sh status
  ```
- **BEFORE** restarting, always check current status
- **NEVER** assume the server state - always verify

### 3. Production Deployment Rules
- **NEVER** deploy to production unless explicitly requested
- **NEVER** run `./deploy.sh` without explicit permission
- **ALWAYS** test changes locally first
- **ALWAYS** ask for confirmation before any production deployment

## Development Workflow Rules

### 1. Local Development Only
- **DEFAULT** to local development environment
- **ALWAYS** work on localhost unless specified otherwise
- **NEVER** modify production database directly

### 2. Database Operations
- **ALWAYS** use local database for testing (bibleai@localhost)
- **NEVER** run migrations on production without explicit request
- **ALWAYS** backup before running migrations (when requested)

### 3. File Operations
- **PREFER** editing existing files over creating new ones
- **NEVER** create documentation unless explicitly requested
- **ALWAYS** check if a file exists before creating it

## Git Operations

### 1. Commit Rules
- **NEVER** commit unless explicitly requested
- **NEVER** push to remote unless explicitly requested
- **ALWAYS** show git status before committing (when requested)

### 2. Branch Management
- **STAY** on current branch unless asked to switch
- **NEVER** merge or rebase without explicit permission

## Error Prevention

### 1. Process Management
- **ALWAYS** use `./server.sh status` to check server state
- **NEVER** attempt to start server if already running
- **ALWAYS** use `./server.sh restart` instead of stop + start

### 2. Script Execution
- **ALWAYS** check if script exists before running
- **ALWAYS** use proper script paths (./script.sh not script.sh)
- **VERIFY** script permissions if execution fails

### 3. Error Handling
- **CHECK** for errors after each operation
- **REPORT** errors immediately without trying to fix automatically
- **ASK** for guidance when encountering unexpected states

## Command Shortcuts

### Approved Auto-Execute Commands
These commands can be run without asking:
- `./server.sh status`
- `./server.sh restart` (for local development)
- `go build`
- `curl` commands for testing
- Database queries with local credentials

### Requires Explicit Permission
These commands always need permission:
- `./deploy.sh`
- `./deploy_backoffice.sh`
- Any production database operations
- Git push operations
- Server stops (without restart)

## File and Directory Awareness

### 1. Deprecated Code
- **NEVER** use code from `deprecated/` directories
- **ALWAYS** check if a directory is deprecated before using
- Files in `deprecated/` are old, unused code - not current implementation
- Look for active code in main project directories

### 2. Current Code Location
- Blog system: Check `internal/handlers/blog.go` and related Go files
- Scripts: Check active script directories, not deprecated ones
- Always verify the directory path doesn't contain "deprecated", "old", "archive", "backup"

## Default Behaviors

1. **Server Changes**: Always use `./server.sh restart`
2. **Code Changes**: Test locally, don't auto-deploy
3. **Database Changes**: Apply to local only
4. **Git Operations**: Show changes, don't auto-commit
5. **Production**: Never touch without explicit request

## Quick Reference

```bash
# Check server status
./server.sh status

# Restart server (local development)
./server.sh restart

# View logs
tail -f server.log

# Test endpoint
curl http://localhost:8080/

# Local database connection
PGPASSWORD=bibleai psql -h localhost -U bibleai -d bibleai
```

---
*These rules are specific to the BibleAI project and should be followed consistently to prevent common issues.*