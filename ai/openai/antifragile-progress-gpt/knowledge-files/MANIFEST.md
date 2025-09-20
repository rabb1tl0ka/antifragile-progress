# Antifragile-Progress Knowledge Files

This folder is the **output location** for building Knowledge files to upload into CustomGPT.

👉 To generate the real knowledge files, run:

```bash
../build-knowledge.sh -z
```

This will produce:
- `FRAMEWORK.md` (copied from repo root)
- `MANIFEST.txt` (auto-generated)
- `knowledge-upload-<timestamp>.zip` (ready to upload)

---

⚠️ Note:  
- `MANIFEST.md` (this file) is just a placeholder so the folder is not empty in Git.  
- The real artifacts (`FRAMEWORK.md`, `MANIFEST.txt`, `.zip`) are **ignored by Git**.
