import hashlib
import json
import sys
import urllib.request
import urllib.error

def sha256_file(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()

def rpc_call(rpc_url: str, method: str, params: list):
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "method": method,
        "params": params
    }).encode("utf-8")

    # Some public RPCs/WAFs block default Python user agents; set an explicit one.
    req = urllib.request.Request(
        rpc_url,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "User-Agent": "VATA-Verify/0.1 (+https://github.com/LHMisme420/VATA-Forensics)"
        }
    )

    with urllib.request.urlopen(req, timeout=30) as resp:
        body = resp.read().decode("utf-8", errors="replace")
        return json.loads(body)

def main():
    if len(sys.argv) < 4:
        print("Usage: python verifier/verify_tx_min.py <file> <tx_hash> <rpc_url>")
        print("Example:")
        print("  python verifier/verify_tx_min.py moltbook.csv 0x... https://ethereum-sepolia-rpc.publicnode.com")
        raise SystemExit(1)

    path = sys.argv[1]
    txh  = sys.argv[2]
    rpc  = sys.argv[3]

    # Local hash
    h = sha256_file(path)
    want = ("0x" + h).lower()

    # Fetch tx
    try:
        res = rpc_call(rpc, "eth_getTransactionByHash", [txh])
    except urllib.error.HTTPError as e:
        # Helpful message for 403/429 WAF/rate-limit situations
        print(f"RPC HTTP error: {e.code} {e.reason}")
        print("Tip: try a different RPC URL, or re-run later if rate-limited.")
        raise SystemExit(2)
    except Exception as e:
        print(f"RPC error: {e}")
        raise SystemExit(2)

    tx = res.get("result")
    if not tx:
        print("Could not fetch tx. Check tx hash and RPC URL.")
        print("RPC response:", json.dumps(res, indent=2)[:800])
        raise SystemExit(3)

    inp = (tx.get("input") or "").lower()

    print("FILE:", path)
    print("SHA256:", want)
    print("TX:", txh)
    print("FROM:", tx.get("from"))
    print("TO:", tx.get("to"))
    print("INPUT (start):", inp[:80] + ("..." if len(inp) > 80 else ""))
    print("INPUT_MATCH:", inp == want)

if __name__ == "__main__":
    main()
