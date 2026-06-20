# Gemma 4 31B Custom Configuration for Cline / Kilo Code

## 1. Executive Summary

When running Gemma 4 31B locally via Ollama, integration conflicts often occur with agentic IDE extensions like **Cline** or **Kilo Code**. These errors stem from architectural changes native to Gemma 4, specifically its internal streaming `<thought>` reasoning blocks and its custom `call:tool_name{}` function syntax.

This repository provides the diagnostic steps, optimized configuration files, and automation scripts required to make Gemma 4 31B compatible with Cline's strict XML tool boundaries on Windows systems.

---

## 2. Core Operational Conflicts

### A. Format and Schema Deviations
* **The Conflict:** Gemma 4 31B naturally formats actions using custom object properties (e.g., `call:tool_name{"arg": "value"}`). Cline demands precise XML-tagged structures like `<write_to_file>` or `<execute_command>`.
* **The Consequence:** Cline reads the response as unformatted text, preventing it from executing terminal actions or creating files.

### B. Inline Token Contamination
* **The Conflict:** The model attempts to emit text summaries, conversational logs, task checklists, and internal reasoning strings simultaneously with the requested code.
* **The Consequence:** Meta-tags such as `<thinking>` or `<attempt_completion>` leak directly into newly created source code files (e.g., `index.html`), corrupting the application code.

### C. Request Timeouts (TTFT Latency)
* **The Conflict:** Cline passes dense context payloads to the local LLM. On consumer hardware, processing this prompt and streaming the first token can exceed the extension's standard limit.
* **The Consequence:** Connection crashes with a 30-second timeout error from the Ollama provider.

---

## 3. Resolution and Optimization Pipeline

### Phase 1: Extension Adjustments
To handle high Time-To-First-Token (TTFT) latency and path mapping on Windows, manually adjust the following in the **VS Code Cline Settings** panel:

1. **Request Timeout:** Increase from `30,000` to `180,000` ms (3 minutes).
2. **Compact Prompt:** Toggle **ON** to reduce token payload size.
3. **Persistent Memory:** Prevent model reloading by running this in a PowerShell window:
   ```powershell
   $env:OLLAMA_KEEP_ALIVE="-1"; ollama serve
   ```
4. **Windows Pathing Injection:** Add the following to Cline's **Custom Instructions** field:
   > CRITICAL FOR ENVIRONMENT: I am on a Windows machine. All file paths must strictly use backslashes (\) and match Windows drive letter standards (e.g., C:\path\to\file). Do not use forward slashes for local workspace paths.

*Detailed steps can be found in [docs/extension-settings.md](docs/extension-settings.md).*

### Phase 2: The Unified Modelfile Architecture
The optimized `Modelfile` intercepts the native reasoning process to prevent stream breakage and locks code generation fields from contamination.

The configuration is located at: `configs/Modelfile`. It includes:
* **Stop Tokens:** Blocks raw `<thought>` tokens from leaking.
* **System Prompt:** Enforces strict XML tool usage and forbids the `call:tool_name` format.

### Phase 3: Compilation and Execution
Instead of manual creation, use the provided setup script to compile the configuration profile into Ollama.

**Execute the following in PowerShell:**
```powershell
# Run the setup script from the repository root
.\scripts\setup.ps1
```

Once completed, select `gemma4-cline` as the model in the Cline API Provider menu and start your task.

---

## Repository Structure
* `configs/Modelfile` - Optimized Ollama model configuration.
* `docs/extension-settings.md` - Detailed guide for IDE extension settings.
* `scripts/setup.ps1` - Automation script to create the `gemma4-cline` model.
* `LICENSE` - Project license information.