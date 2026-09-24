#!/usr/bin/env bash
# Pre-publication guard for this repository.
#
# Checks for PATTERNS, never for literal secret or personal values, so this
# script is itself safe to publish. Known-benign hits go in tools/allowlist.txt
# with a reason.
#
#   ./tools/check-public-safe.sh [repo_dir] [source_dir]
#
# Exit 0 = clean. Exit 1 = something needs looking at before you push.
#
# NOTE ON grep: this script deliberately does NOT use grep. The `grep` on this
# machine is a shell function wrapping ugrep with --ignore-files, which honours
# .gitignore silently. A grep-based guard reports clean on exactly the files
# most worth catching, because those are the ones that get gitignored. The scan
# below is Python so there is no such surprise.

set -uo pipefail
ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SRC="${2:-$HOME/Documents/Code/Project3229}"

python3 - "$ROOT" "$SRC" "$ROOT/tools/allowlist.txt" <<'PY'
import hashlib, math, os, re, sys

root, src, allow_path = sys.argv[1], sys.argv[2], sys.argv[3]

allow = set()
if os.path.exists(allow_path):
    for line in open(allow_path, encoding="utf-8"):
        line = line.split("#")[0].strip()
        if line:
            allow.add(line.lower())

SKIP_DIRS = {".git", "node_modules", "__pycache__", ".venv"}
# The scanner defines the very patterns it looks for, so it matches itself on
# every run. It is skipped here and reviewed by hand instead.
SKIP_FILES = {os.path.join("tools", "check-public-safe.sh"),
              os.path.join("tools", "allowlist.txt")}
BANNED_EXT = {".png", ".jpg", ".jpeg", ".tif", ".tiff", ".svg", ".psd", ".ai"}

# --- 1. credential names, prefixes and key blocks -------------------------
CREDENTIAL = [
    re.compile(r"REPLICATE_API_TOKEN"),
    re.compile(r"GELATO_API_KEY"),
    re.compile(r"\br8_[A-Za-z0-9]{8,}"),
    re.compile(r"\bsk-[A-Za-z0-9]{12,}"),
    re.compile(r"\bghp_[A-Za-z0-9]{20,}"),
    re.compile(r"\b(?:AKIA|ASIA)[0-9A-Z]{16}\b"),
    re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH |)PRIVATE KEY-----"),
]

# --- 2. business terms that must never appear -----------------------------
TERMS = ["wilt club", "wiltclub", "rankhero", "pinterest trends",
         "printify", "gelato", "etsy", "shopify"]

# --- 3. third-party identifiers that leak as URLs, not prose --------------
DOMAINS = ["slothhikingclub.com", "muir-way.com", "national-park-posters.com",
           "andersondesigngroupstore.com", "quiver.ai", "claude.ai"]

# --- 4. personal identifiers, by shape rather than by value ---------------
EMAIL = re.compile(r"\b[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}\b")
PHONE = re.compile(r"(?<!\d)(?:\+?1[ .\-])?\(?\d{3}\)?[ .\-]\d{3}[ .\-]\d{4}(?!\d)")
STREET = re.compile(r"\b\d{1,5}[A-Za-z]?[ \-]\d{0,5}\s?\w*\s+"
                    r"(?:Street|St|Avenue|Ave|Road|Rd|Drive|Dr|Lane|Ln|Way|Blvd|Boulevard|Court|Ct|Place|Pl)\b",
                    re.I)
EMAIL_OK = ("example.com", "example.org", "noreply.github.com")

# --- 5. paths that should never be referenced -----------------------------
PATHS = [re.compile(r"(?<![\w.])\.env(?:\.[\w]+)?\b"),
         re.compile(r"\.pem\b"), re.compile(r"\.key\b")]

# --- 6. high-entropy strings ----------------------------------------------
TOKEN = re.compile(r"[A-Za-z0-9+/=_\-]{20,}")

def entropy(s):
    if not s:
        return 0.0
    return -sum((n / len(s)) * math.log2(n / len(s))
                for n in (s.count(c) for c in set(s)))

findings, warnings = [], []

def add(kind, rel, lineno, hit, line):
    if hit.lower() in allow:
        return
    findings.append((kind, rel, lineno, hit, line.strip()[:110]))

# --- collect source text for the near-identical check ---------------------
src_hashes, src_lines = set(), set()
for dirpath, dirnames, filenames in os.walk(src):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
    for fn in filenames:
        p = os.path.join(dirpath, fn)
        try:
            raw = open(p, "rb").read()
        except OSError:
            continue
        src_hashes.add(hashlib.sha256(raw).hexdigest())
        try:
            for ln in raw.decode("utf-8", "ignore").splitlines():
                ln = " ".join(ln.split())
                if len(ln.split()) >= 12:
                    src_lines.add(ln)
        except Exception:
            pass

# --- scan the repo ---------------------------------------------------------
for dirpath, dirnames, filenames in os.walk(root):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        rel = os.path.relpath(path, root)
        if rel in SKIP_FILES:
            continue
        ext = os.path.splitext(fn)[1].lower()

        if ext in BANNED_EXT:
            findings.append(("ASSET", rel, 0, ext, "generated assets must not ship"))
            continue

        try:
            raw = open(path, "rb").read()
        except OSError:
            continue

        if hashlib.sha256(raw).hexdigest() in src_hashes:
            findings.append(("COPIED", rel, 0, "byte-identical",
                             "identical to a file in the source workspace: rewrite it"))

        text = raw.decode("utf-8", "ignore")
        for lineno, line in enumerate(text.splitlines(), 1):
            low = line.lower()

            for rx in CREDENTIAL:
                for m in rx.finditer(line):
                    add("CREDENTIAL", rel, lineno, m.group(0), line)

            for t in TERMS:
                if t in low:
                    add("TERM", rel, lineno, t, line)

            for dm in DOMAINS:
                if dm in low:
                    add("DOMAIN", rel, lineno, dm, line)

            for m in EMAIL.finditer(line):
                if not m.group(0).lower().endswith(EMAIL_OK):
                    add("EMAIL", rel, lineno, m.group(0), line)
            for m in PHONE.finditer(line):
                add("PHONE", rel, lineno, m.group(0), line)
            for m in STREET.finditer(line):
                add("ADDRESS", rel, lineno, m.group(0), line)

            # The PATH rule catches documents that reference a secret file.
            # .gitignore exists to name those patterns, so it is exempt from
            # this rule only. Every other rule still applies to it.
            if os.path.basename(rel) != ".gitignore":
                for rx in PATHS:
                    for m in rx.finditer(line):
                        add("PATH", rel, lineno, m.group(0), line)

            for m in TOKEN.finditer(line):
                tok = m.group(0)
                if ("/" in tok or "\\" in tok or tok.count("_") > 2
                        or len(tok) < 24 or entropy(tok) <= 4.2):
                    continue
                if tok.lower() not in allow:
                    add("ENTROPY", rel, lineno, tok[:12] + "...", line)

            norm = " ".join(line.split())
            if len(norm.split()) >= 12 and norm in src_lines:
                warnings.append(("VERBATIM", rel, lineno, "",
                                 "line appears word-for-word in a source file"))

# --- report ---------------------------------------------------------------
if warnings:
    print(f"\n{len(warnings)} warning(s) - not blocking, but look:\n")
    for kind, rel, lineno, _, note in warnings:
        print(f"  [{kind}] {rel}:{lineno}  {note}")

if findings:
    print(f"\n{len(findings)} finding(s) - resolve before publishing:\n")
    for kind, rel, lineno, hit, ctx in findings:
        print(f"  [{kind}] {rel}:{lineno}")
        print(f"      {hit}")
        print(f"      {ctx}")
    print("\nIf a hit is genuinely benign, add the exact value to "
          "tools/allowlist.txt with a reason.")
    sys.exit(1)

print("  safety check: clean")
sys.exit(0)
PY
