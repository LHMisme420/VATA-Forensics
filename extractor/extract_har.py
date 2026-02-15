import json, csv, glob

rows = []

for file in glob.glob("*.har"):
    with open(file,"r",encoding="utf-8") as f:
        har = json.load(f)

    entries = har.get("log",{}).get("entries",[])
    for e in entries:
        resp = e.get("response",{})
        content = resp.get("content",{})
        text = content.get("text","")
        if text:
            rows.append([file, text[:1000]])

with open("moltbook.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["source_har","payload_excerpt"])
    w.writerows(rows)

print("moltbook.csv created")
