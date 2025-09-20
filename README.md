# Antifragile-Progress

**Less complexity → More momentum.**  
A lean framework to help you make steady progress on ideas, projects and initiatives by avoiding overthinking and over-engineering.

---

## Why this exists
- Turn fuzzy ideas into **clear, lean moves**.  
- Escape traps of **future-problem-solving**.  
- Protect energy and **unlock momentum**.  
- Build progress that grows stronger under stress which is what I call *antifragile progress*.  

---

## Quick start
1. Read [`FRAMEWORK.md`](./FRAMEWORK.md) for the Core Checks.  
2. Use the GitHub Issue template under `.github/ISSUE_TEMPLATE/` to run a check.  
3. Decide: **Proceed Lean**, **Simplify**, **Park**, or **Kill** (rare).  
4. If “Proceed,” commit to a **one-day test** that proves adoption/impact.

---

## Using with CustomGPT

- **Instructions (System Prompt):**  
  Copy from [`customgpt/INSTRUCTIONS.md`](./customgpt/INSTRUCTIONS.md).  

- **Knowledge upload:**  
  Use the files listed in [`customgpt/knowledge/MANIFEST.txt`](./customgpt/knowledge/MANIFEST.txt).  
  By default this includes:  
  - [`FRAMEWORK.md`](./FRAMEWORK.md)  
  - [`templates/checklist.md`](./templates/checklist.md)  

- **Conversation Starters & Description:**  
  Provided in the [`customgpt/`](./customgpt/) folder.

---

## Releasing

Releases are managed with [`make-release.sh`](./make-release.sh).

- **Preview release notes:**  
  ```bash
  ./make-release.sh --preview v0.3.0
  ```

- **Tag & publish release:**  
  ```bash
  ./make-release.sh v0.3.0
  ```

- **Force retag if needed:**  
  ```bash
  ./make-release.sh --force v0.3.0
  ```

Each release automatically builds the **CustomGPT knowledge bundle** under:
```
ai/openai/antifragile-progress-gpt/knowledge-files/
```
including a timestamped zip for upload.

---

## License
MIT — free to use, adapt, and improve.
