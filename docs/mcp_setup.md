# Model Context Protocol (MCP) Setup Guide

This document records the setup process and configuration used to integrate the Model Context Protocol (MCP) in the Antigravity system for the `asi.surge.sh` project.

## Step-by-Step UI Configuration for Antigravity

The MCP is configured to provide the AI Agent with access to specialized external tools natively via MCP servers. Below are the official steps to navigate the Antigravity IDE and mount these servers.

### Step 1: Open the Agent Panel and Find the MCP Option
* Open Google Antigravity on your computer.
* On the right side, locate the **Agent panel**.
* Click the `...` (three dots) button in the top-right corner of the panel.
* Select **MCP Servers** from the dropdown menu.

### Step 2: Access the MCP Configuration
While the store provides pre-built templates, resilient enterprise use requires Manual Config:
1. Click **Manage MCP Servers**.
2. Click **View raw config**.
3. This opens the `mcp_config.json` file, usually located at `%userprofile%\.gemini\antigravity\mcp_config.json` on Windows.

### Step 3: Configure for Use (GitHub MCP Example)
Our primary integration is the **GitHub MCP Server**, which provides the agent with the ability to read, search, and modify the GitHub repository natively. A resilient configuration block for Windows looks like this:

```json
{
  "mcpServers": {
    "github": {
      "command": "C:\\Program Files\\nodejs\\npx.cmd",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<REDACTED_FOR_SECURITY>",
        "PATH": "<INSERT_YOUR_SYSTEM_PATH_HERE>"
      }
    }
  }
}
```

> [!NOTE]
> **WSL Update Requirement:** Windows Subsystem for Linux (WSL) might need to be updated for the environment servers to function properly. 
> 
> * **How to open PowerShell:** Press the Windows Key, type "PowerShell", right-click on **Windows PowerShell**, and select **Run as Administrator**.
> * **Command:** Run `wsl --update` inside the PowerShell window. 
> * **Important:** You may need to run this command *multiple times* until it confirms no further updates are available.

> [!IMPORTANT]
> **Post-Update Restart:** Once WSL has been successfully updated, you **must close Antigravity**. Ideally, you should **reboot the computer entirely**, and then open Antigravity again once the computer reboots. 
> 
> After resuming, you may continue with **Step 4** below.

### Components
- **Server Name**: `github`
- **Executor**: `C:\Program Files\nodejs\npx.cmd` - We use the absolute path to `npx.cmd` on Windows. This prevents the "executable not found" path-resolution bug that frequently plagues IDEs and agentic environments when relying simply on `"npx"`. 
- **Package**: `@modelcontextprotocol/server-github` (Fetched automatically via the `-y` flag)
- **Environment Variables**:
  - `GITHUB_PERSONAL_ACCESS_TOKEN`: A fine-grained personal access token required for the MCP server to authenticate and act on behalf of the user to manipulate the repository (read/write issues, comments, commits, pull requests, etc.).
  - `PATH`: Explicitly forwarding the user's system `%PATH%` ensures that the MCP Server itself can access dependencies (like docker, git, etc.) downstream.

### Step 4: Save and Verify
* Save the `mcp_config.json` file.
* Go back to the **Manage MCP Servers** screen in Antigravity and click **Refresh**.
* Verify the connection: A green indicator (or active status) should appear next to the server name, and its tools will be available for the agent to use in the chat.

## Future References for Developers
- **Resilient Execution**: Never rely on shorthand `npx`. Ensure you run `where npx` in your terminal to find your exact Node.js installation path to replace the generic `command` value.
- **Environment Scope**: Run `echo %PATH%` in your terminal and paste it into the `env.PATH` value in your JSON.
- If the MCP connection fails, regenerate the GitHub Personal Access Token and securely update the `mcp_config.json` file. Let the AI know the token has been rotated.
- Do **not** commit the actual `mcp_config.json` containing live tokens to any source control.
