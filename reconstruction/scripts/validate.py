import json, sys, collections
from rdflib import Graph, Dataset, URIRef, RDF
from rdflib.namespace import RDFS
import networkx as nx
from pyshacl import validate

SRC, OUT = sys.argv[1], sys.argv[2]
BRANDS = ["boehringer-ingelheim", "jardiance", "ofev"]
KG = "urn:kg:vocab:"
ok = True
def check(cond, msg):
    global ok
    print(("OK   " if cond else "FAIL ") + msg); ok &= bool(cond)

ont = Graph().parse(f"{OUT}/ontology/bi_kg_ontology.ttl")
ent = Graph().parse(f"{OUT}/rdf/enterprise.ttl")
ds = Dataset(); ds.parse(f"{OUT}/rdf/bi_kg_all.trig", format="trig")
check(len(list(ds.quads())) > 0, f"TriG reparsed: {len(list(ds.quads()))} quads")
G = nx.read_graphml(f"{OUT}/graphml/bi_kg_all.graphml")
check(True, f"GraphML reparsed: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")

shacl = {}
for b in BRANDS:
    D = json.load(open(f"{SRC}/data/{b}.data.jsonld"))
    orig_nodes = {n["@id"]: n["@type"] for n in D["nodes"]}
    orig_edges = collections.Counter((r["source"], r["@type"], r["target"]) for r in D["relationships"])
    ttl = Graph().parse(f"{OUT}/rdf/{b}.ttl")
    if any(n.get("graphScope") == "enterprise" for n in D["nodes"]): ttl = ttl + ent
    shapes = Graph().parse(f"{OUT}/ontology/shapes_{b}.ttl")
    _d = Dataset(); _d.parse(f"{OUT}/jsonld/{b}.graph.jsonld", format="json-ld")
    jl = Graph()
    for q in _d.quads(): jl.add(q[:3])
    for name, g in [("ttl", ttl), ("jsonld", jl)]:
        types = {str(s): str(o)[len(KG):] for s, o in g.subject_objects(RDF.type) if str(o).startswith(KG)}
        check(all(types.get(i) == t for i, t in orig_nodes.items()) and len(types) == len(orig_nodes),
              f"{b} {name}: {len(types)} typed nodes == {len(orig_nodes)} original, same types")
        rels = {(str(s), str(p)[len(KG):], str(o)) for s, p, o in g if isinstance(o, URIRef) and p != RDF.type}
        check(rels == set(orig_edges), f"{b} {name}: {len(rels)} edges == {len(set(orig_edges))} distinct original edges (raw {sum(orig_edges.values())})")
        # literal values preserved
        bad = 0
        for n in D["nodes"]:
            for k, v in n.items():
                if k.startswith("@") or v is None or k == "data": continue
                vals = [x.toPython() for x in g.objects(URIRef(n["@id"]), URIRef(KG + k))]
                if v not in vals: bad += 1
        check(bad == 0, f"{b} {name}: all property values round-trip (mismatches={bad})")
    check(sum(1 for i in orig_nodes if G.has_node(i)) == len(orig_nodes), f"{b} graphml: all nodes present")
    conforms, rg, txt = validate(ttl, shacl_graph=shapes, ont_graph=ont, inference="rdfs", advanced=True)
    res = collections.Counter()
    focus = collections.defaultdict(list)
    for r in rg.subjects(RDF.type, URIRef("http://www.w3.org/ns/shacl#ValidationResult")):
        m = str(rg.value(r, URIRef("http://www.w3.org/ns/shacl#resultMessage")))
        res[m] += 1; focus[m].append(str(rg.value(r, URIRef("http://www.w3.org/ns/shacl#focusNode"))))
    shacl[b] = {"conforms": conforms, "results": dict(res)}
    print(f"     SHACL {b}: conforms={conforms} {dict(res)}")
json.dump(shacl, open(f"{OUT}/validation/shacl_summary.json", "w"), indent=1)
print("ALL OK" if ok else "SOME CHECKS FAILED")
