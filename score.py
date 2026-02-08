# score.py  (replace current content or add import fix)
import argparse
import pickle
import json
from vata.provenance import verify_artifact_provenance   # ← this line assumes vata/ exists

def main():
    parser = argparse.ArgumentParser(description="VATA Artifact Score")
    parser.add_argument("--artifact", required=True, help="Path to artifact")
    parser.add_argument("--model", default="model.pkl")
    args = parser.parse_args()

    with open(args.model, "rb") as f:
        model = pickle.load(f)  # even if dummy, this loads

    # Placeholder score + check
    score = 0.82
    valid = verify_artifact_provenance(args.artifact)

    result = {"score": score, "provenance_ok": valid, "artifact": args.artifact}
    print(result)
    with open("result.json", "w") as f:
        json.dump(result, f, indent=2)

if __name__ == "__main__":
    main()
