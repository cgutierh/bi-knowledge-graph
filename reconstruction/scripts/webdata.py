import json, sys, collections
SRC, OUT = sys.argv[1], sys.argv[2]
BR = ["boehringer-ingelheim", "jardiance", "ofev"]
D = {b: json.load(open(f"{SRC}/data/{b}.data.jsonld")) for b in BR}
O = {b: json.load(open(f"{SRC}/ontology/{b}.ontology.jsonld")) for b in BR}
TEXT = ["claim_text", "reference_text", "statement_text", "indication_text", "outcome_text", "rule_text", "text"]
def label(n):
    t = n["@type"]
    if t == "Document": return n["source_file_name"]
    for f in ["name", "trial_name", "module_name", "sheet_name"]:
        if n.get(f): return n[f]
    if t == "Chunk": return f"Chunk {n.get('chunk_index')} · p. {n.get('page_number')}"
    if t in ("Section", "PISection") and n.get("section_title"): return n["section_title"]
    for f in TEXT:
        if n.get(f):
            s = " ".join(n[f].split())
            return s[:110] + ("…" if len(s) > 110 else "")
    return n["@id"].rsplit(":", 1)[-1]
nodes, idx, edges = [], {}, []
types, rtypes = [], []
def ti(lst, v):
    if v not in lst: lst.append(v)
    return lst.index(v)
for b in BR:
    for n in D[b]["nodes"]:
        if n["@id"] in idx: continue
        kg = "enterprise" if n.get("graphScope") == "enterprise" else b
        props = {k: v for k, v in n.items() if not k.startswith("@") and v is not None and k != "graphScope"}
        idx[n["@id"]] = len(nodes)
        nodes.append([n["@id"], ti(types, n["@type"]), kg, label(n), props])
seen = set()
for b in BR:
    for r in D[b]["relationships"]:
        k = (r["source"], r["@type"], r["target"])
        if k in seen: continue
        seen.add(k); edges.append([idx[r["source"]], ti(rtypes, r["@type"]), idx[r["target"]]])
classes = {}
for b in BR:
    for layer, key in [("domain", "domainOntology"), ("prov", "documentProvenanceOntology")]:
        for e in O[b][key]["entityTypes"]:
            c = classes.setdefault(e["name"], {"layer": layer, "def": {}, "rules": [], "req": []})
            c["def"][b] = e["description"]
            for r in e.get("validation_rules", []):
                if r not in c["rules"]: c["rules"].append(r)
            for f in e.get("required_fields", []):
                if f not in c["req"]: c["req"].append(f)
rels = {}
for b in BR:
    for r in O[b]["relationshipTypes"]:
        x = rels.setdefault(r["name"], {"desc": r["description"], "src": [], "tgt": []})
        if r["source"] not in x["src"]: x["src"].append(r["source"])
        if r["target"] not in x["tgt"]: x["tgt"].append(r["target"])
graphs = {b: {"name": D[b]["knowledgeGraph"]["name"], "generatedAt": D[b]["generatedAt"]} for b in BR}
graphs["enterprise"] = {"name": "Enterprise", "generatedAt": None}
json.dump({"graphs": graphs, "types": types, "rtypes": rtypes, "nodes": nodes, "edges": edges, "classes": classes, "rels": rels},
          open(f"{OUT}/kg.json", "w"), ensure_ascii=False, separators=(",", ":"))
print(len(nodes), len(edges), types)
