# Model Context Protocol (MCP) Setup Guide
**Created On:** 2026-04-18 19:58 EDT (2026-04-18 23:58 UTC)

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

### Step 3: Create GitHub Personal Access Token
Before configuring the GitHub MCP server, you must generate a Fine-grained Personal Access Token (PAT). Please follow the [official GitHub Guidelines for generating a fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).
* **Expiration Date:** Ensure the token is time-bound (e.g., 30, 60, or 90 days) for security.
* **Permissions:** Select **Only select repositories** (e.g., `stellardreams/asi.surge.sh`) and grant **Repository Permissions** necessary for the agent to function (e.g., Read/Write access for Issues, Pull Requests, Contents, Commit statuses, and Metadata).
* **Secure Storage:** The generated Personal Access Token will only be demonstrated to the user for a brief moment. Once you close the user interface in GitHub, the token will be gone forever. The user is entirely responsible for storing their keys in a secure manner, best to consult with a world-class and accredited computer and network security professional.

### Step 4: Configure for Use (GitHub Docker Server Example)
Our primary integration relies on the **Docker-Based GitHub MCP Server** to provide the agent with the ability to read, search, and modify the GitHub repository natively out of a secure sandbox. A resilient configuration block looks like this:

```json
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-e",
        "GITHUB_PERSONAL_ACCESS_TOKEN",
        "mcp/github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<REDACTED_FOR_SECURITY>"
      }
    }
  }
}
```

> [!TIP]
> Make sure the Docker Daemon (Docker Desktop) is actively running in the background before you refresh or open Antigravity.

#### Troubleshooting: Docker Backend Setup
If you encounter a "failed to connect to the docker API" or a named pipe (`npipe`) connection error, verify these three critical settings in Docker Desktop:

1. **Expose Daemon on TCP (Crucial Fix)**
   * **Location:** Settings > General
   * **Setting:** Check "Expose daemon on tcp://localhost:2375 without TLS".
   * **Why:** This gives the agent's internal machinery a standard network port to talk to the Docker daemon, bypassing unreliable native Windows pipes.
2. **WSL 2 Backend Integration**
   * **Location:** Settings > General
   * **Setting:** Ensure "Use the WSL 2 based engine" is enabled.
   * **Why:** Modern workflows rely on the faster, properly integrated Linux kernel rather than the legacy Hyper-V engine.
3. **Host File Entries (Optional)**
   * We typically recommend keeping "Add the `.docker.internal` names to the host's `/etc/hosts` file" **unchecked** to avoid constant administrator privilege prompts during your workflow, unless absolutely required for complex custom DNS.

> [!NOTE]
> **WSL Update Requirement:** Windows Subsystem for Linux (WSL) might need to be updated for the environment servers to function properly. 
> 
> * **How to open PowerShell:** Press the Windows Key, type "PowerShell", right-click on **Windows PowerShell**, and select **Run as Administrator**.
> * **Command:** Run `wsl --update` inside the PowerShell window. 
> * **Important:** You may need to run this command *multiple times* until it confirms no further updates are available.

> [!IMPORTANT]
> **Post-Update Restart:** Once WSL has been successfully updated, you **must close Antigravity**. Ideally, you should **reboot the computer entirely**, and then open Antigravity again once the computer reboots. 
> 
> After resuming, you may continue with **Step 5** below.

### Step 5: Save and Verify
* Save the `mcp_config.json` file.
* Go back to the **Manage MCP Servers** screen in Antigravity and click **Refresh**.
* Verify the connection: A green indicator (or active status) should appear next to the server name, and its tools will be available for the agent to use in the chat.

## Local NPX-Based Configuration Alternative

> [!CAUTION]
> **Security Sandbox Warning:** Executing agentic server tools directly on the host machine using `npx` provides **zero isolation or sandboxing**. In the event of a supply chain attack (e.g., a poisoned `npm` package) or an indirect prompt injection attack against the AI agent, the `npx` process will execute with your user's full system privileges. This could allow malicious actors to quietly read and exfiltrate proprietary source code, local environment variables, and private keys. We strongly advise utilizing the Docker container infrastructure in Step 4.

If Docker is absolutely unavailable, you can adapt the logic above to use a local `npx` installation. 

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

#### Components & Troubleshooting for NPX
- **Executor**: `C:\Program Files\nodejs\npx.cmd` - We use the absolute path to `npx.cmd` on Windows. This prevents the "executable not found" path-resolution bug that frequently plagues IDEs and agentic environments when relying simply on `"npx"`. 
- **Environment Variables**:
  - `PATH`: Explicitly forwarding the user's system `%PATH%` ensures that the MCP Server itself can access dependencies downstream.
- **Resilient Execution**: Never rely on shorthand `npx`. Ensure you run `where npx` in your terminal to find your exact Node.js installation path.
- **Environment Scope**: Run `echo %PATH%` in your terminal and paste it into the `env.PATH` value in your JSON.

## Future References for Developers
- If the MCP connection fails inside Docker or NPX, regenerate the GitHub Personal Access Token and securely update the `mcp_config.json` file. Let the AI know the token has been rotated.
- Do **not** commit the actual `mcp_config.json` containing live tokens to any source control.

---

## Legal Disclaimer ⚖️
1. `@genidma` and any names, entities, or group of companies mentioned in this document (including Google, Gemini, and DeepMind) are not responsible in any way for the manner through which this information is implemented.
2. This information is being documented strictly for internal use only, hosted on a repository that `@genidma` has chosen to make fully public (and within reason).
3. There is no official alliance or formal affiliation between `@genidma` and any organization mentioned in this document, particularly Google or Alphabet Inc., at this time.
4. By continuing to use this information (which is available via Google and other search engines), you absolve us of any and all responsibility and liability in any court of law, anywhere.

## Authorship

* **Primary Logic**: [Gemini (Google DeepMind)](https://gemini.google.com/)
* **Co-author**: [Antigravity (Google DeepMind)](https://antigravity.google)
* **Reviewer**: [@genidma](https://github.com/genidma)
