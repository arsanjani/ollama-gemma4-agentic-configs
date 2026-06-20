## Gemma 4 31B Custom Configuration for Cline / Kilo Code

## 1. Executive Summary

* When running Gemma 4 31B locally via Ollama, integration conflicts occur naturally with agentic IDE extensions like Cline or Kilo Code. These errors stem from architectural changes native to Gemma 4, specifically its internal streaming <thought> reasoning blocks and its custom call:tool_name{} function syntax. This report compiles the diagnostic steps and custom configurations required to make Gemma 4 31B perfectly compatible with Cline's strict XML tool boundaries on Windows systems.
------------------------------
## 2. Core Operational Conflicts## A. Format and Schema Deviations

* The Conflict: Gemma 4 31B naturally formats actions using custom object properties (e.g., call:tool_name{"arg": "value"}). Cline demands precise XML-tagged structures like <write_to_file> or <execute_command>.
* The Consequence: Cline reads the response as unformatted text, preventing it from executing the requested terminal actions or creating files.

## B. Inline Token Contamination

* The Conflict: The model attempts to emit text summaries, conversational logs, task checklists, and internal reasoning strings simultaneously with the requested code.
* The Consequence: Meta-tags such as <thinking> or <attempt_completion> leak directly into newly created source code files (e.g., index.html or style.css), corrupting the application code.

## C. Request Timeouts (TTFT Latency)

* The Conflict: Cline passes dense context payloads (system prompts, workspaces, and tool schemas) to the local LLM. On standard consumer hardware, processing this prompt and streaming the first token exceeds the standard extension limit.
* The Consequence: Connection crashes out with a 30 seconds timeout error from the Ollama provider.

------------------------------
## 3. Resolution and Optimization Pipeline## Phase 1: Environment and Extension Adjustments
To handle high Time-To-First-Token (TTFT) latency and path mapping on Windows, the following extension configurations must be manually adjusted inside the VS Code Cline Settings panel:

   1. Request Timeout Modification: Increase the value from 30000 to 180000 milliseconds (3 minutes) to accommodate heavy prompt ingestion on the GPU.
   2. Compact Prompt Activation: Toggle "Use Compact Prompt" to ON. This cuts down the token payload size sent to Ollama, reducing initial model calculation times.
   3. Persistent Memory Allocation: Force Ollama to cache the 31B parameters continuously inside system RAM/VRAM, preventing delays caused by constant model reloading. This is executed in a persistent Windows PowerShell window:
   
   $env:OLLAMA_KEEP_ALIVE="-1"; ollama serve
   
   [2] 
   4. Windows Pathing Injection: Append the following text block directly into Cline's Custom Instructions text field to prevent Linux-style pathing errors:
   
   CRITICAL FOR ENVIRONMENT: I am on a Windows machine. All file paths must strictly use backslashes (\) and match Windows drive letter standards (e.g., C:\path\to\file). Do not use forward slashes for local workspace paths.
   
   
## Phase 2: The Unified Modelfile Architecture
The following optimized model blueprint intercepts the native reasoning process before it breaks the stream, hardcodes structural compliance, and locks code generation fields from conversational contamination.
Create a text file with no extension named Modelfile inside C:\OllamaConfigs\Modelfile and input this configuration:

FROM gemma4:31b
# Intercept and block raw reasoning tokens so they do not leak to Cline
PARAMETER stop "<thought>"
PARAMETER stop "</thought>"

SYSTEM """
You are acting as an elite software engineering agent inside Cline (and Kilo Code). You must communicate your actions EXCLUSIVELY by wrapping tool usage inside valid XML tags (such as <write_to_file>, <replace_in_file>, or <execute_command>) as requested by the extension.

CRITICAL FORMATTING AND SYSTEM RULES:
1. Do NOT use the `call:tool_name` format under any circumstances.
2. Do NOT output plain text thought blocks or markdown summaries of your actions before or inside your tool tags. Output the XML block immediately.
3. When using a file manipulation tool (e.g., <write_to_file>), the content inside those tags must contain ONLY raw, valid programming code (HTML, CSS, JS, etc.).
4. NEVER include conversational summaries, markdown explanations, checklists, your thoughts, or <thinking> tags INSIDE a file writing tool block.
5. Any explanation, user update, task checklist, or <attempt_completion> block must happen completely OUTSIDE and AFTER the file writing tool tags are fully closed.
"""

## Phase 3: Compilation and Execution
To compile the settings, execute these lines sequentially in a Windows PowerShell console:

# Navigate to the config folder
cd C:\OllamaConfigs\
# Compile the modified configuration profile into Ollama
ollama create gemma4-cline -f .\Modelfile

Once the generation finishes, target gemma4-cline as the designated model inside the Cline API Provider menu, clear the task history using the New Task (+) button, and resume local software development operations.
