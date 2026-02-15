import hashlib
import streamlit as st
from web3 import Web3

st.set_page_config(page_title="VATA Verify", layout="centered")
st.title("VATA Verify")
st.caption("Upload a file → compute SHA-256 → compare to Ethereum tx calldata (input).")

RPC_DEFAULT = "https://ethereum-sepolia-rpc.publicnode.com"

def sha256_hex(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()

st.subheader("1) Upload file")
up = st.file_uploader("Upload dataset (CSV/ZIP/TXT/JSON)", type=None)

computed = None
if up is not None:
    computed = sha256_hex(up.getvalue())
    st.success("Computed SHA-256")
    st.code("0x" + computed)

st.subheader("2) Verify against on-chain calldata")
rpc = st.text_input("RPC URL", value=RPC_DEFAULT)
txh = st.text_input("Transaction hash (0x...)")

if st.button("Verify", type="primary", disabled=(computed is None or not txh.strip())):
    try:
        w3 = Web3(Web3.HTTPProvider(rpc.strip()))
        if not w3.is_connected():
            st.error("RPC not reachable.")
        else:
            tx = w3.eth.get_transaction(txh.strip())
            inp = (tx.get("input") or "").lower()
            want = ("0x" + computed).lower()

            st.write("Tx from:", tx.get("from"))
            st.write("Tx to:", tx.get("to"))

            if inp == want:
                st.success("VERIFIED ✅ tx calldata matches SHA-256 of uploaded file")
            else:
                st.error("NOT VERIFIED ❌")
                st.caption("Expected calldata:")
                st.code(want)
                st.caption("Actual calldata (start):")
                st.code(inp[:100] + ("..." if len(inp) > 100 else ""))
    except Exception as e:
        st.error(f"Error: {e}")
