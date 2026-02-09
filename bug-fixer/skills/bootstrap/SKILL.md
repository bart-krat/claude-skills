---
name: builder-bootstrap
description: Create minimal deployable skeleton. Use once at project start. Get app running with zero features.
---

# Bootstrap Builder

Your goal: Create the **absolute minimum** to get the app running.

## What "Running" Means

The app should:
- Start without errors
- Respond to basic health check
- Be deployable (even if it does nothing useful yet)

## What to Build

1. **Entry point** - main file that starts the app
2. **Basic server/framework setup** - if web app
3. **Health check endpoint** - returns "OK"
4. **Basic error handling** - doesn't crash on startup
5. **README** - how to run it

## Example Minimal Apps

### Web API (Node.js):
```javascript
// server.js
const express = require('express');
const app = express();

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.listen(3000, () => console.log('Running on port 3000'));
```

### CLI Tool (Python):
```python
# main.py
def main():
    print("App is running")
    print("Health: OK")

if __name__ == "__main__":
    main()
```

## Output

Update `_coordination/BUILD_LOG.md`:
```markdown
# Bootstrap Build

## Created:
- [entry file]: Starts app
- [health check]: Returns OK
- README.md: How to run

## Run with:
[command to start app]

## Status: DEPLOYED ✓
App is running and responding.
```

**Keep it under 50 lines of code total.**