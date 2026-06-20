# Gemma 4 Cline Configuration for Windows

A professional optimization suite for running **Gemma 4 31B** locally via Ollama, specifically tailored for agentic IDE extensions like **Cline** and **Kilo Code**.

## 🚀 Quick Start

### 1. Environment Setup
Apply the manual settings in VS Code as detailed in [Extension Settings](docs/extension-settings.md).

### 2. Deploy Optimized Model
Run the automation script to compile your custom model profile:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

### 3. Select Model
In the Cline API Provider menu, select `gemma4-cline` as your designated model. Clear task history and start developing!

## ⚠️ The Agentic Challenge

Running large models like Gemma 4 31B locally within agentic frameworks (Cline, Kilo Code) often introduces "Agentic Drift"—where the model's internal reasoning interferes with its ability to execute tools correctly. 

**The primary issues include:**
- **Syntax Mismatch:** The model naturally uses custom function calls (`call:tool_name{}`) instead of the strict XML tags required by the IDE extensions.
- **Output Contamination:** Internal reasoning blocks and conversational summaries leak into generated source code, corrupting files.
- **Latency Timeouts:** Large context payloads cause TTFT (Time-To-First-Token) delays that trigger extension timeouts.

### 🛠️ Our Resolution Strategy
We resolve these issues by implementing a three-layered approach:
1. **The Unified Modelfile**: Hardcodes strict XML tool boundaries and intercepts raw reasoning tokens to prevent leakage.
2. **Environment Tuning**: Optimizes the VS Code extension timeout and prompt compression to handle local LLM latency.
3. **Windows Pathing Injection**: Forces consistent backslash pathing to avoid cross-platform compatibility errors on Windows systems.

## 📁 Repository Structure

- `configs/`: Contains the `Modelfile` used to create the customized Ollama model.
- `scripts/`: Automation scripts for deploying the configuration.
- `docs/`: Detailed documentation on extension settings and environment variables.

---
*Based on the Gemma 4 31B Custom Configuration Report.*