import json, sys, collections
SRC, OUT = sys.argv[1], sys.argv[2]
BR = ["boehringer-ingelheim", "jardiance", "ofev"]
O = {b: json.load(open(f"{SRC}/ontology/{b}.ontology.jsonld")) for b in BR}
D = {b: json.load(open(f"{SRC}/data/{b}.data.jsonld")) for b in BR}
PROV = {"Document", "Section", "Chunk", "Table"}
classes = {}
for b in BR:
    for layer, key in [("domain", "domainOntology"), ("prov", "documentProvenanceOntology")]:
        for e in O[b][key]["entityTypes"]:
            c = classes.setdefault(e["name"], {"name": e["name"], "layer": layer, "brands": [], "def": {}, "req": [], "rules": [], "counts": {}})
            c["brands"].append(b); c["def"][b] = e["description"]
            for f in e.get("required_fields", []):
                if f not in c["req"]: c["req"].append(f)
            for r in e.get("validation_rules", []):
                if r not in c["rules"]: c["rules"].append(r)
for b in BR:
    for t, n in collections.Counter(x["@type"] for x in D[b]["nodes"]).items():
        classes[t]["counts"][b] = n
rels = {}
for b in BR:
    for r in O[b]["relationshipTypes"]:
        x = rels.setdefault(r["name"], {"name": r["name"], "src": set(), "tgt": set(), "desc": r["description"], "brands": [], "counts": {}})
        x["src"].add(r["source"]); x["tgt"].add(r["target"]); x["brands"].append(b)
    for t, n in collections.Counter(x["@type"] for x in D[b]["relationships"]).items():
        rels[t]["counts"][b] = n
for r in rels.values(): r["src"] = sorted(r["src"]); r["tgt"] = sorted(r["tgt"])

# business-layer graph (aggregated)
nodes, links = {}, []
def add(i, **k): nodes.setdefault(i, {"id": i, **k})
for b in BR:
    N = D[b]["nodes"]; byid = {n["@id"]: n for n in N}; kgname = D[b]["knowledgeGraph"]["name"]
    bid = f"urn:kg:{b}:brand:{b}"
    add(bid, type="Brand", label=kgname if b == "boehringer-ingelheim" else kgname, kg=b)
    docs = {n["source_document_id"]: n for n in N if n["@type"] == "Document"}
    for did, d in docs.items():
        i = f"doc:{did}"; add(i, type="Document", label=d["source_file_name"], kg=b, sub=d["source_document_type"] + (f" · {d['market']}" if d.get("market") else ""))
        links.append({"s": bid, "t": i, "type": "BRAND_HAS_DOCUMENT"})
    agg = collections.Counter()
    for n in N:
        t = n["@type"]
        if t in ("Section", "Chunk", "PISection", "SafetyStatement", "ToneRule", "VisualRule"):
            agg[(n.get("source_document_id"), t)] += 1
    for (did, t), cnt in agg.items():
        i = f"agg:{b}:{did}:{t}"
        add(i, type=t, label=f"{cnt} {t}", kg=b, agg=cnt)
        links.append({"s": f"doc:{did}", "t": i, "type": "contiene"})
    for n in N:
        t = n["@type"]
        if t in ("ClinicalTrial", "CardiovascularOutcome", "RenalOutcome", "RespiratoryOutcome", "Indication", "Market", "ContentModule", "Table"):
            lab = n.get("trial_name") or n.get("name") or n.get("module_name") or n.get("sheet_name") or (n.get("indication_text") or n.get("outcome_text") or "")[:70]
            sub = n.get("nct_number") or n.get("market") or ""
            full = n.get("indication_text") or n.get("outcome_text")
            add(n["@id"], type=t, label=lab, kg=("enterprise" if n.get("graphScope") == "enterprise" else b), sub=sub, full=full)
            if t not in ("Market",) and n.get("source_document_id") in docs:
                links.append({"s": f"doc:{n['source_document_id']}", "t": n["@id"], "type": "DERIVED_FROM"})
    for r in D[b]["relationships"]:
        if r["@type"] in ("BRAND_TARGETS_MARKET", "MARKET_PART_OF_REGION", "OUTCOME_FROM_TRIAL", "RENAL_OUTCOME_FROM_TRIAL"):
            links.append({"s": r["source"], "t": r["target"], "type": r["@type"]})
    # claims aggregated per content module + status
    cc = collections.Counter()
    for r in D[b]["relationships"]:
        if r["@type"] == "CONTENT_MODULE_CONTAINS_CLAIM":
            cc[(r["source"], byid[r["target"]]["claim_status"])] += 1
    for (mid, st), cnt in cc.items():
        i = f"claims:{mid}:{st}"; add(i, type="Claim", label=f"{cnt} claims · {st}", kg=b, agg=cnt, status=st)
        links.append({"s": mid, "t": i, "type": "CONTENT_MODULE_CONTAINS_CLAIM"})
# dedupe links
seen = set(); L = []
for l in links:
    k = (l["s"], l["t"], l["type"])
    if k in seen or l["s"] not in nodes or l["t"] not in nodes: continue
    seen.add(k); L.append(l)
meta = {b: {"name": D[b]["knowledgeGraph"]["name"], "nodes": D[b]["nodeCount"], "rels": D[b]["relationshipCount"],
            "generatedAt": D[b]["generatedAt"], "docs": sum(1 for n in D[b]["nodes"] if n["@type"] == "Document")} for b in BR}
shacl = json.load(open(f"{OUT}/validation/shacl_summary.json"))
json.dump({"classes": list(classes.values()), "rels": list(rels.values()), "graph": {"nodes": list(nodes.values()), "links": L}, "meta": meta, "shacl": shacl},
          open("site/kgdata.json", "w"), ensure_ascii=False)
print(len(classes), len(rels), len(nodes), len(L))
