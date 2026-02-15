import hashlib, sys

file = sys.argv[1]

with open(file,"rb") as f:
    h = hashlib.sha256(f.read()).hexdigest()

print(h)
