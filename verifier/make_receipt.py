import hashlib, json, os, platform, sys, time, glob

def sha256_file(p: str) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def main():
    folder = sys.argv[1] if len(sys.argv) > 1 else "."
    patterns = ["*.har", "*.csv", "*.zip", "*.json", "*.txt", "*.md", "*.log"]
    paths = []
    for pat in patterns:
        paths += glob.glob(os.path.join(folder, pat))

    artifacts = []
    for p in sorted(set(paths)):
        artifacts.append({
            "path": os.path.relpath(p, folder).replace("\\", "/"),
            "sha256": sha256_file(p),
            "bytes": os.path.getsize(p),
        })

    receipt = {
        "vata_receipt": "0.1",
        "created_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "machine": {
            "platform": platform.platform(),
            "python": sys.version.split()[0],
        },
        "folder": os.path.abspath(folder),
        "artifacts": artifacts,
    }

    out_path = os.path.join(folder, "receipt.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(receipt, f, indent=2)

    print("Wrote", out_path)

if __name__ == "__main__":
    main()
