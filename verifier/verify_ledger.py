import json, sys, urllib.request

def rpc_call(rpc, method, params):
    payload = json.dumps({
        "jsonrpc": "2.0",
        "id": 1,
        "method": method,
        "params": params
    }).encode()

    req = urllib.request.Request(
        rpc,
        data=payload,
        headers={
            "Content-Type": "application/json",
            "User-Agent": "VATA-Ledger-Verify/0.1"
        }
    )

    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

def main():
    ok = True

    with open("ledger.jsonl","r",encoding="utf-8") as f:
        for line in f:
            if not line.strip():
                continue
            entry = json.loads(line)

            tx = entry["tx_hash"]
            want = entry["calldata"].lower()
            rpc = entry["rpc"]

            res = rpc_call(rpc,"eth_getTransactionByHash",[tx])
            txobj = res.get("result")

            if not txobj:
                print("FAIL fetch:", tx)
                ok = False
                continue

            inp = (txobj.get("input") or "").lower()

            if inp != want:
                print("MISMATCH:", tx)
                print(" expected:", want)
                print(" got     :", inp)
                ok = False
            else:
                print("OK:", entry["name"])

    if not ok:
        sys.exit(1)

if __name__ == "__main__":
    main()
