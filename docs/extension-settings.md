# Extension Settings for Cline / Kilo Code

To ensure the best performance and compatibility with Gemma 4 31B on Windows, please apply the following settings within the VS Code extension panel:

## 🛠️ Manual Configuration Steps

### 1. Request Timeout Modification
**Change:** Increase timeout from `30,000` to `180,000` milliseconds (3 minutes).
- **Why?** High Time-To-First-Token (TTFT) latency on consumer hardware prevents connection crashes during heavy prompt ingestion.

### 2. Compact Prompt Activation
**Change:** Toggle `"Use Compact Prompt"` $\rightarrow$ **ON**.
- **Why?** Reduces the token payload size sent to Ollama, accelerating initial model calculations.

### 3. Persistent Memory Allocation (Ollama Serve)
Execute the following command in a persistent Windows PowerShell window to prevent constant model reloading:
```powershell
$env:OLLAMA_KEEP_ALIVE="-1"; ollama serve
```

## 📝 Custom Instructions Injection
Add the following block to your **Custom Instructions** field in the Cline settings to ensure correct pathing on Windows:

> CRITICAL FOR ENVIRONMENT: I am on a Windows machine. All file paths must strictly use backslashes (\) and match Windows drive letter standards (e.g., C:\path\to\file). Do not use forward slashes for local workspace paths.

---
*Last Updated: 2026-06-20*