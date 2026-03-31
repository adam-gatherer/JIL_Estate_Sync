# create_overview.py
# Cross-platform project overview generator

import os
from pathlib import Path

# ============================================================
# CONFIG
# ============================================================

WHITELIST_EXTENSIONS = {".py", ".txt", ".tf", ".tfvars", ".sh", ".yml"}

EXCLUDE_DIRS = {
    ".git",
    "__pycache__",
    ".venv",
    "venv",
    "env",
    "ENV",
    ".mypy_cache",
    ".pytest_cache",
    "LICENSE",
    "create_overview.py",""
    ".terraform"
}

ROOT = Path.cwd()
OUT = ROOT / f"{ROOT.name}_overview.txt"


# ============================================================
# Helpers
# ============================================================


def is_excluded(path: Path):
    return any(part in EXCLUDE_DIRS for part in path.parts)


# ============================================================
# TREE GENERATION (excluding noise dirs)
# ============================================================


def generate_tree(root: Path):
    lines = []

    for path in sorted(root.rglob("*")):
        if is_excluded(path):
            continue

        rel = path.relative_to(root)
        depth = len(rel.parts) - 1
        indent = "│   " * depth
        prefix = "├── "
        lines.append(f"{indent}{prefix}{rel}")

    return "\n".join(lines)


# ============================================================
# FILE CONTENT SECTION (whitelist only)
# ============================================================


def should_include_content(path: Path):
    if path == OUT:
        return False
    if is_excluded(path):
        return False
    if path.suffix.lower() not in WHITELIST_EXTENSIONS:
        return False
    return True


def generate_file_contents(root: Path):
    sections = []

    for path in sorted(root.rglob("*")):
        if path.is_file() and should_include_content(path):
            rel = path.relative_to(root)
            sections.append(f"FILENAME: {rel}\n")
            try:
                with open(path, "r", encoding="utf-8", errors="ignore") as f:
                    sections.append(f.read())
            except Exception:
                sections.append("[Could not read file]")
            sections.append("\n\n\n")

    return "".join(sections)


# ============================================================
# MAIN
# ============================================================


def main():
    print("Generating project overview...")

    tree_section = generate_tree(ROOT)
    content_section = generate_file_contents(ROOT)

    with open(OUT, "w", encoding="utf-8") as f:
        f.write(tree_section)
        f.write("\n\n")
        f.write(content_section)

    print(f"Overview written to {OUT}")


if __name__ == "__main__":
    main()
