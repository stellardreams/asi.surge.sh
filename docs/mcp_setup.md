# Model Context Protocol (MCP) Setup Guide

This document records the setup process and configuration used to integrate the Model Context Protocol (MCP) in the Antigravity system for the `asi.surge.sh` project.

## Configuration Details

The MCP is configured to provide the AI Agent with access to specialized external tools by interacting with MCP servers. Our primary integration is the **GitHub MCP Server**, which provides the agent with the ability to read, search, and modify the GitHub repository natively.

### Configuration File
The MCP configuration is stored locally in the Antigravity App Data directory under `mcp_config.json` (`~/.gemini/antigravity/mcp_config.json`).

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<REDACTED_FOR_SECURITY>"
      }
    }
  }
}
```

### Components
- **Server Name**: `github`
- **Executor**: `npx` (Node Package Execute)
- **Package**: `@modelcontextprotocol/server-github` (Fetched automatically via the `-y` flag)
- **Environment Variables**:
  - `GITHUB_PERSONAL_ACCESS_TOKEN`: A fine-grained personal access token required for the MCP server to authenticate and act on behalf of the user to manipulate the repository (read/write issues, comments, commits, pull requests, etc.).

## Future References for Developers
- Ensure Node.js and `npx` are installed and available in the system path.
- If the MCP connection fails, regenerate the GitHub Personal Access Token and securely update the `mcp_config.json` file. Let the AI know the token has been rotated.
- Do **not** commit the actual `mcp_config.json` containing live tokens to any source control.
