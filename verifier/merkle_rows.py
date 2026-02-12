import hashlib, sys

def h(b: bytes) -> bytes:
    return hashlib.sha256(b).digest()

def merkle_root(leaves: list[bytes]) -> bytes:
    if not leaves:
        return b"\x00" * 32
    level = [h(x) for x in leaves]
    while len(level) > 1:
        if len(level) % 2 == 1:
            level.append(level[-1])
        nxt = []
        for i in range(0, len(level), 2):
            nxt.append(h(level[i] + level[i+1]))
        level = nxt
    return level[0]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python verifier/merkle_rows.py <file>")
        raise SystemExit(1)

    path = sys.argv[1]
    data = open(path, "rb").read()
    rows = [r for r in data.splitlines() if r.strip()]
    root = merkle_root(rows).hex()

    print(root)
