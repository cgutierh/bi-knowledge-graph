"""Reconstruct the BI Knowledge Graph export into standard semantic formats.

Usage: python3 -I build.py <export_dir> <out_dir>
"""
import json, sys, os, collections, csv, glob
from rdflib import Graph, Dataset, URIRef, Literal, BNode, Namespace
from rdflib.namespace import RDF, RDFS, OWL, XSD, SKOS, DCTERMS, PROV, VOID
from rdflib.collection import Collection

SRC, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
BRANDS = ["boehringer-ingelheim", "jardiance", "ofev"]
KG = Namespace("urn:kg:vocab:")
SH = Namespace("http://www.w3.org/ns/shacl#")
RDFJSON = URIRef("http://www.w3.org/1999/02/22-rdf-syntax-ns#JSON")

ONT = {b: json.load(open(f"{SRC}/ontology/{b}.ontology.jsonld")) for b in BRANDS}
DATA = {b: json.load(open(f"{SRC}/data/{b}.data.jsonld")) for b in BRANDS}

PROV_TYPES = {"Document", "Section", "Chunk", "Table"}
OUTCOMES = {"CardiovascularOutcome", "RenalOutcome", "RespiratoryOutcome"}
INT_FIELDS = set()
for b in BRANDS:
    for n in DATA[b]["nodes"]:
        for k, v in n.items():
            if isinstance(v, int) and not isinstance(v, bool):
                INT_FIELDS.add(k)

def bind(g):
    for p, ns in [("kg", KG), ("owl", OWL), ("rdfs", RDFS), ("xsd", XSD), ("skos", SKOS),
                  ("dcterms", DCTERMS), ("prov", PROV), ("sh", SH), ("void", VOID)]:
        g.bind(p, ns)

# ---------------------------------------------------------------- ontology
def entity_defs(b):
    o = ONT[b]
    return {e["name"]: e for e in o["domainOntology"]["entityTypes"] + o["documentProvenanceOntology"]["entityTypes"]}

E = {b: entity_defs(b) for b in BRANDS}
R = {b: {r["name"]: r for r in ONT[b]["relationshipTypes"]} for b in BRANDS}
all_classes = sorted(set().union(*E.values()))
all_rels = sorted(set().union(*R.values()))

o = Graph(); bind(o)
ont = URIRef("urn:kg:vocab:ontology")
o.add((ont, RDF.type, OWL.Ontology))
o.add((ont, RDFS.label, Literal("BI Knowledge Graph Ontology (reconstructed from JSON export)", lang="en")))
o.add((ont, RDFS.comment, Literal(
    "OWL/RDFS rendering of the three ontology overlays (boehringer-ingelheim / 'Life Forward', jardiance, ofev). "
    "Term IRIs keep the original urn:kg:vocab: namespace so the original JSON-LD data stays compatible.", lang="en")))
for b in BRANDS:
    o.add((ont, DCTERMS.source, Literal(f"ontology/{b}.ontology.jsonld")))
    o.add((ont, OWL.versionInfo, Literal(f"{b}: generatedAt {ONT[b]['generatedAt']}")))
for kind, desc in ONT["jardiance"]["locatorSourceKinds"].items():
    o.add((ont, KG.locatorSourceKind, Literal(f"{kind}: {desc}", lang="en")))

# annotation properties
for ap, lab in [("requiredField", "required field"), ("optionalField", "optional field"),
                ("validationRule", "validation rule"), ("allowedSourceDocumentType", "allowed source document type"),
                ("ontologyModule", "ontology module"), ("declaredInOverlay", "declared in overlay"),
                ("locatorSourceKind", "locator source kind")]:
    o.add((KG[ap], RDF.type, OWL.AnnotationProperty)); o.add((KG[ap], RDFS.label, Literal(lab, lang="en")))

# overlays
o.add((KG.OntologyOverlay, RDF.type, OWL.Class))
for b in BRANDS:
    ov = KG[f"overlay/{b}"]
    kgm = ONT[b]["knowledgeGraph"]
    o.add((ov, RDF.type, KG.OntologyOverlay)); o.add((ov, RDF.type, OWL.NamedIndividual))
    o.add((ov, RDFS.label, Literal(f"{kgm['name']} ({b})")))
    for m in ONT[b]["domainOntology"]["ontologyModules"]:
        o.add((ov, KG.ontologyModule, Literal(f"{m['name']} [{m['layer']}]")))

# abstract superclasses (added for reconstruction)
for c, lab, com in [("DomainEntity", "Domain entity", "Business/medical concept (domainOntology). Added during reconstruction: the export's DERIVED_FROM_* relations name 'DomainEntity' as source without declaring it."),
                    ("ProvenanceEntity", "Provenance entity", "Structural entity describing where knowledge came from (documentProvenanceOntology)."),
                    ("ClinicalOutcome", "Clinical outcome", "Added during reconstruction: common parent of brand-specific outcome classes.")]:
    o.add((KG[c], RDF.type, OWL.Class)); o.add((KG[c], RDFS.label, Literal(lab, lang="en"))); o.add((KG[c], RDFS.comment, Literal(com, lang="en")))
o.add((KG.ProvenanceEntity, RDFS.subClassOf, PROV.Entity))
o.add((KG.DomainEntity, OWL.disjointWith, KG.ProvenanceEntity))
o.add((KG.ClinicalOutcome, RDFS.subClassOf, KG.DomainEntity))

class_report = {}
for c in all_classes:
    cu = KG[c]
    defs = {b: E[b][c] for b in BRANDS if c in E[b]}
    o.add((cu, RDF.type, OWL.Class)); o.add((cu, RDFS.label, Literal(c, lang="en")))
    parent = KG.ProvenanceEntity if c in PROV_TYPES else (KG.ClinicalOutcome if c in OUTCOMES else KG.DomainEntity)
    o.add((cu, RDFS.subClassOf, parent))
    if c == "Document":
        o.add((cu, RDFS.subClassOf, PROV.Entity))
    descs = {b: d["description"] for b, d in defs.items()}
    if len(set(descs.values())) == 1:
        o.add((cu, SKOS.definition, Literal(next(iter(descs.values())), lang="en")))
    else:
        base = descs.get("boehringer-ingelheim") or next(iter(descs.values()))
        o.add((cu, SKOS.definition, Literal(base, lang="en")))
        for b, d in descs.items():
            if d != base:
                o.add((cu, SKOS.scopeNote, Literal(f"[{b}] {d}", lang="en")))
    if len(defs) < len(BRANDS):
        for b in defs:
            o.add((cu, KG.declaredInOverlay, KG[f"overlay/{b}"]))
    seen = set()
    for b, d in defs.items():
        for f in d.get("required_fields", []):
            if ("r", f) not in seen: o.add((cu, KG.requiredField, Literal(f))); seen.add(("r", f))
        for f in d.get("optional_fields", []):
            if ("o", f) not in seen: o.add((cu, KG.optionalField, Literal(f))); seen.add(("o", f))
        for t in d.get("allowed_source_document_types", []):
            if ("t", t) not in seen: o.add((cu, KG.allowedSourceDocumentType, Literal(t))); seen.add(("t", t))
        for vr in d.get("validation_rules", []):
            tag = "" if all(vr in dd.get("validation_rules", []) for dd in defs.values()) and len(defs) == 3 else f"[{b}] "
            key = ("v", tag + vr)
            if key not in seen: o.add((cu, KG.validationRule, Literal(tag + vr, lang="en"))); seen.add(key)
    class_report[c] = sorted(defs)

def class_expr(names):
    names = sorted(set(names))
    if names == ["DomainEntity"]: return KG.DomainEntity
    if len(names) == 1: return KG[names[0]]
    if set(names) <= OUTCOMES: return KG.ClinicalOutcome
    u = BNode(); lst = BNode(); Collection(o, lst, [KG[n] for n in names])
    o.add((u, RDF.type, OWL.Class)); o.add((u, OWL.unionOf, lst)); return u

HASPART = {"DOCUMENT_HAS_SECTION", "DOCUMENT_HAS_TABLE", "SECTION_HAS_CHUNK", "CONTENT_MODULE_CONTAINS_CLAIM", "PI_SECTION_CONTAINS_SAFETY"}
rel_report = {}
for r in all_rels:
    ru = KG[r]
    defs = {b: R[b][r] for b in BRANDS if r in R[b]}
    o.add((ru, RDF.type, OWL.ObjectProperty)); o.add((ru, RDFS.label, Literal(r, lang="en")))
    o.add((ru, RDFS.domain, class_expr([d["source"] for d in defs.values()])))
    o.add((ru, RDFS.range, class_expr([d["target"] for d in defs.values()])))
    descs = sorted(set(d["description"] for d in defs.values()))
    o.add((ru, SKOS.definition, Literal(descs[0], lang="en")))
    for extra in descs[1:]: o.add((ru, SKOS.scopeNote, Literal(extra, lang="en")))
    if r.startswith("DERIVED_FROM_"): o.add((ru, RDFS.subPropertyOf, PROV.wasDerivedFrom))
    if r == "CLAIM_DERIVED_FROM_DOCUMENT": o.add((ru, RDFS.subPropertyOf, KG.DERIVED_FROM_DOCUMENT))
    if r in HASPART: o.add((ru, RDFS.subPropertyOf, DCTERMS.hasPart))
    if r == "MARKET_PART_OF_REGION": o.add((ru, RDFS.subPropertyOf, DCTERMS.isPartOf))
    if len(defs) < len(BRANDS):
        for b in defs: o.add((ru, KG.declaredInOverlay, KG[f"overlay/{b}"]))
    rel_report[r] = {b: (d["source"], d["target"]) for b, d in defs.items()}

# datatype properties: every field named in the ontology or observed in data
fields = set()
for b in BRANDS:
    for d in E[b].values(): fields |= set(d.get("required_fields", [])) | set(d.get("optional_fields", []))
    for n in DATA[b]["nodes"]: fields |= {k for k in n if not k.startswith("@")}
for f in sorted(fields):
    fu = KG[f]
    o.add((fu, RDF.type, OWL.DatatypeProperty)); o.add((fu, RDFS.label, Literal(f, lang="en")))
    o.add((fu, RDFS.range, RDFJSON if f == "data" else (XSD.integer if f in INT_FIELDS else XSD.string)))
os.makedirs(f"{OUT}/ontology", exist_ok=True)
o.serialize(f"{OUT}/ontology/bi_kg_ontology.ttl", format="turtle")

# ---------------------------------------------------------------- SHACL (one shapes graph per overlay: required fields differ by brand)
def build_shapes(b):
    s = Graph(); bind(s)
    for c, d in sorted(E[b].items()):
        shape = KG[f"shape/{b}/{c}"]
        s.add((shape, RDF.type, SH.NodeShape)); s.add((shape, SH.targetClass, KG[c]))
        req = set(d.get("required_fields", [])); allowed = d.get("allowed_values", {})
        for f in sorted(req | set(allowed)):
            p = BNode(); s.add((shape, SH.property, p)); s.add((p, SH.path, KG[f]))
            if f in req:
                s.add((p, SH.minCount, Literal(1)))
                s.add((p, SH.message, Literal(f"{c}: required field '{f}' is missing")))
            if f in allowed:
                lst = BNode(); Collection(s, lst, [Literal(v) for v in sorted(allowed[f])]); s.add((p, SH["in"], lst))
        for rr in sorted(d.get("required_relationships", [])):
            p = BNode(); s.add((shape, SH.property, p)); s.add((p, SH.path, KG[rr])); s.add((p, SH.minCount, Literal(1)))
            s.add((p, SH.message, Literal(f"{c}: required relationship {rr} is missing")))
    if any("Safety Information" in vr for vr in E[b]["Claim"].get("validation_rules", [])):
        eff = KG[f"shape/{b}/EfficacyClaimRequiresSafety"]
        s.add((eff, RDF.type, SH.NodeShape)); s.add((eff, SH.targetClass, KG.Claim))
        sp = BNode(); s.add((eff, SH.sparql, sp))
        s.add((sp, SH.message, Literal("Efficacy claim has no CLAIM_REQUIRES_SAFETY link (ontology rule: every efficacy claim must carry the required Safety Information)")))
        s.add((sp, SH.select, Literal("""PREFIX kg: <urn:kg:vocab:>
SELECT $this WHERE {
  $this kg:key_message_type ?t .
  FILTER(CONTAINS(LCASE(STR(?t)), "efficacy"))
  FILTER NOT EXISTS { $this kg:CLAIM_REQUIRES_SAFETY ?s }
}""")))
    return s
os.makedirs(f"{OUT}/ontology", exist_ok=True)
for b in BRANDS:
    build_shapes(b).serialize(f"{OUT}/ontology/shapes_{b}.ttl", format="turtle")

# ---------------------------------------------------------------- data
os.makedirs(f"{OUT}/rdf", exist_ok=True); os.makedirs(f"{OUT}/jsonld", exist_ok=True)
LABEL_FIELDS = ["name", "trial_name", "module_name", "sheet_name", "source_file_name", "section_title"]
def label_of(n):
    t = n["@type"]
    if t == "Document": return n.get("source_file_name")
    for f in LABEL_FIELDS:
        if n.get(f): return n[f]
    return None

def lit(k, v):
    if k == "data": return Literal(json.dumps(v, ensure_ascii=False), datatype=RDFJSON)
    if isinstance(v, bool): return Literal(v)
    if isinstance(v, int): return Literal(v, datatype=XSD.integer)
    return Literal(v)

ds = Dataset(); bind(ds)
meta = ds.graph(URIRef("urn:kg:export:metadata"))
ent_graph = ds.graph(URIRef("urn:kg:enterprise:graph"))
stats = {}
seen_enterprise = set()
for b in BRANDS:
    D = DATA[b]
    gid = URIRef(f"urn:kg:{b}:graph")
    g = ds.graph(gid)
    out_edges = collections.defaultdict(lambda: collections.defaultdict(list))
    for r in D["relationships"]:
        out_edges[r["source"]][r["@type"]].append(r["target"])
    jl_nodes = []
    for n in D["nodes"]:
        u = URIRef(n["@id"])
        target = g
        if n.get("graphScope") == "enterprise":
            target = ent_graph
            if n["@id"] in seen_enterprise: target = None
            seen_enterprise.add(n["@id"])
        if target is not None:
            target.add((u, RDF.type, KG[n["@type"]]))
            lab = label_of(n)
            if lab: target.add((u, RDFS.label, Literal(lab)))
            for k, v in n.items():
                if k.startswith("@") or v is None: continue
                target.add((u, KG[k], lit(k, v)))
        # JSON-LD node (fixed format) — every node kept in its brand file
        jn = {k: v for k, v in n.items() if v is not None}
        if "data" in jn: jn["data"] = {"@value": jn["data"], "@type": "@json"}
        for rt, tgts in out_edges.get(n["@id"], {}).items():
            jn[rt] = [{"@id": t} for t in tgts]
        jl_nodes.append(jn)
    for r in D["relationships"]:
        g.add((URIRef(r["source"]), KG[r["@type"]], URIRef(r["target"])))
    # metadata
    kgm = D["knowledgeGraph"]
    meta.add((gid, RDF.type, VOID.Dataset)); meta.add((gid, RDFS.label, Literal(kgm["name"])))
    meta.add((gid, DCTERMS.identifier, Literal(kgm["slug"]))); meta.add((gid, DCTERMS.created, Literal(D["generatedAt"], datatype=XSD.dateTime)))
    meta.add((gid, KG.kind, Literal(kgm["kind"]))); meta.add((gid, KG.status, Literal(kgm["status"])))
    meta.add((gid, KG.nodeCount, Literal(D["nodeCount"]))); meta.add((gid, KG.relationshipCount, Literal(D["relationshipCount"])))
    meta.add((gid, KG.derivedProvenanceRelationshipCount, Literal(D["derivedProvenanceRelationshipCount"])))
    meta.add((gid, KG.textNormalization, Literal(json.dumps(D["textNormalization"], ensure_ascii=False), datatype=RDFJSON)))
    meta.add((gid, VOID.vocabulary, URIRef("urn:kg:vocab:")))
    meta.add((gid, DCTERMS.source, Literal(f"data/{b}.data.jsonld")))
    # fixed JSON-LD
    ctx = {"@vocab": "urn:kg:vocab:", "xsd": "http://www.w3.org/2001/XMLSchema#",
           "rdfs": "http://www.w3.org/2000/01/rdf-schema#"}
    for rt in sorted({r["@type"] for r in D["relationships"]}):
        ctx[rt] = {"@type": "@id", "@container": "@set"}
    for f in sorted(INT_FIELDS): ctx[f] = {"@type": "xsd:integer"}
    jl = {"@context": ctx, "@id": f"urn:kg:{b}:graph", "rdfs:label": kgm["name"],
          "generatedAt": {"@value": D["generatedAt"], "@type": "xsd:dateTime"}, "@graph": jl_nodes}
    json.dump(jl, open(f"{OUT}/jsonld/{b}.graph.jsonld", "w"), ensure_ascii=False)
    g.serialize(f"{OUT}/rdf/{b}.ttl", format="turtle")
    stats[b] = {"nodes": len(D["nodes"]), "edges": len(D["relationships"]), "triples": len(g)}
meta.add((URIRef("urn:kg:enterprise:graph"), RDF.type, VOID.Dataset))
meta.add((URIRef("urn:kg:enterprise:graph"), RDFS.comment, Literal("Shared enterprise-scope nodes referenced by brand graphs (only Market nodes are present in this export; their source ai_disclosure_matrix.xlsx is not included).", lang="en")))
ds.serialize(f"{OUT}/rdf/bi_kg_all.trig", format="trig")
ent_graph.serialize(f"{OUT}/rdf/enterprise.ttl", format="turtle")

# ---------------------------------------------------------------- GraphML
import networkx as nx
G = nx.MultiDiGraph()
for b in BRANDS:
    for n in DATA[b]["nodes"]:
        attrs = {k: (json.dumps(v, ensure_ascii=False) if isinstance(v, (dict, list)) else v)
                 for k, v in n.items() if not k.startswith("@") and v is not None}
        attrs.update(type=n["@type"], kg=("enterprise" if n.get("graphScope") == "enterprise" else b),
                     label=str(label_of(n) or n["@type"])[:120])
        G.add_node(n["@id"], **attrs)
    for r in DATA[b]["relationships"]:
        G.add_edge(r["source"], r["target"], key=f"{b}{r['@id']}", type=r["@type"], kg=b)
os.makedirs(f"{OUT}/graphml", exist_ok=True)
nx.write_graphml(G, f"{OUT}/graphml/bi_kg_all.graphml")

# ---------------------------------------------------------------- Neo4j Cypher (LOAD CSV over the original CSV folder)
csv.field_size_limit(10**9)
lines = ["// Neo4j import for the original CSV export.",
         "// Copy the csv/ folder into Neo4j's import/ directory, then run this script (e.g. cypher-shell -f neo4j_import.cypher).",
         "// Every node also gets the :KGNode label so relationship files with mixed endpoint labels can be matched on id.",
         "CREATE CONSTRAINT kgnode_id IF NOT EXISTS FOR (n:KGNode) REQUIRE n.id IS UNIQUE;", ""]
for b in BRANDS:
    for f in sorted(glob.glob(f"{SRC}/csv/{b}/nodes/*.csv")):
        label = os.path.basename(f)[:-4]
        hdr = next(csv.reader(open(f)))
        sets = []
        for h in hdr:
            if h == "id": continue
            if h in INT_FIELDS: sets.append(f"n.`{h}` = toInteger(row.`{h}`)")
            else: sets.append(f"n.`{h}` = row.`{h}`")
        lines += [f"// {b} :: {label}",
                  f"LOAD CSV WITH HEADERS FROM 'file:///csv/{b}/nodes/{label}.csv' AS row",
                  "CALL { WITH row",
                  f"  MERGE (n:KGNode {{id: row.id}}) SET n:`{label}`,",
                  "    " + ",\n    ".join(sets) + ",",
                  f"    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE '{b}' END",
                  "} IN TRANSACTIONS OF 1000 ROWS;", ""]
for b in BRANDS:
    for f in sorted(glob.glob(f"{SRC}/csv/{b}/relationships/*.csv")):
        rt = os.path.basename(f)[:-4]
        lines += [f"// {b} :: {rt}",
                  f"LOAD CSV WITH HEADERS FROM 'file:///csv/{b}/relationships/{rt}.csv' AS row",
                  "CALL { WITH row",
                  "  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})",
                  f"  MERGE (a)-[:`{rt}`]->(z)",
                  "} IN TRANSACTIONS OF 1000 ROWS;", ""]
os.makedirs(f"{OUT}/neo4j", exist_ok=True)
open(f"{OUT}/neo4j/neo4j_import.cypher", "w").write("\n".join(lines))

json.dump({"stats": stats, "classes": class_report, "rels": rel_report}, open(f"{OUT}/build_report.json", "w"), indent=1)
print(json.dumps(stats, indent=1))
print("ontology triples", len(o), "dataset quads", len(list(ds.quads())))
