# Antifragile-Progress

<img src="./assets/logo.png" alt="Antifragile-Progress Logo" width="300"/>

**Less complexity. More momentum.**  
A lean framework to help you make steady progress on ideas, projects, and initiatives by avoiding overthinking and over-engineering.

---

## Why this exists
- Turn fuzzy ideas into **clear, lean moves**.  
- Escape traps of **future-problem-solving**.  
- Protect energy and **unlock momentum**.  
- Build progress that grows stronger under stress — *antifragile progress*.  

---

## Quick start
1. Read [`FRAMEWORK.md`](./FRAMEWORK.md) for the 5 Checks and outcomes.  
2. Check the [Releases](./releases) for ready-to-use versions of the framework.  
3. (Optional) Load the framework into an AI by exploring the [`ai/`](./ai/) folder.  

---

## Using with CustomGPT (AntifragileProgressGPT)

**Instructions (System Prompt):**  
Copy from [`customgpt/INSTRUCTIONS.md`](./customgpt/INSTRUCTIONS.md). This is the single source of truth for the prompt.

**Knowledge upload (files to upload in the CustomGPT UI):**  
1) Generate the knowledge files from the GPT-specific folder:  
   ```bash
   cd ai/openai/antifragile-progress-gpt/
   ./build-knowledge.sh -z
   ```
2) This will populate `ai/openai/antifragile-progress-gpt/knowledge-files/` with:
   - `FRAMEWORK.md` (copied from repo root; **upload this** to CustomGPT → Knowledge)
   - `MANIFEST.txt` (dev builds) or `MANIFEST-<version>.txt` (on releases; **informational only**)
   - `knowledge-upload-<...>.zip` (optional convenience bundle)

**Important paths:**  
- Scripts live in: `ai/openai/antifragile-progress-gpt/`  
- Output lives in: `ai/openai/antifragile-progress-gpt/knowledge-files/`  
- A placeholder `MANIFEST.md` is version-controlled in that folder so it isn’t empty; build outputs are gitignored.

**Conversation Starters & Description:**  
Provided in the [`customgpt/`](./customgpt/) folder (`STARTERS.md`, `DESCRIPTION.md`).

---

## Releasing

Releases are managed with [`make-release.sh`](./make-release.sh). This will also build a **versioned Knowledge bundle** for the GPT.

- **Preview release notes:**  
  ```bash
  ./make-release.sh --preview v1.0.0
  ```

- **Tag & publish release:**  
  ```bash
  ./make-release.sh v1.0.0
  ```

- **Force retag if needed:**  
  ```bash
  ./make-release.sh --force v1.0.0
  ```

Each release automatically creates under:
```
ai/openai/antifragile-progress-gpt/knowledge-files/
```
- `FRAMEWORK.md` (copied)  
- `MANIFEST-<version>.txt` (version-stamped)  
- `knowledge-upload-<version>.zip` (if `zip` is available)

---

## License
MIT — free to use, adapt, and improve.
