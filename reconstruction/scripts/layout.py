import json, sys, math, networkx as nx, numpy as np, time
K = json.load(open(sys.argv[1])); out = sys.argv[2]
N = K["nodes"]; E = K["edges"]
order = ["boehringer-ingelheim", "jardiance", "ofev"]
home = [n[2] if n[2] != "enterprise" else "jardiance" for n in N]
pos = [None] * len(N); x_off = 0.0; t0 = time.time()
for b in order:
    idx = [i for i in range(len(N)) if home[i] == b]
    G = nx.Graph(); G.add_nodes_from(idx)
    G.add_edges_from((s, t) for s, _, t in E if s in G and t in G)
    p = nx.spring_layout(G, k=1.6 / math.sqrt(len(idx)), iterations=120, seed=7)
    a = np.array([p[i] for i in idx]); a -= a.mean(0)
    r = np.percentile(np.linalg.norm(a, axis=1), 98) or 1
    scale = math.sqrt(len(idx)) * 10
    a = a / r * scale
    x_off += scale
    for i, (x, y) in zip(idx, a): pos[i] = [round(float(x + x_off), 2), round(float(y), 2)]
    x_off += scale + 60
# class graph
C = nx.Graph(); types = K["types"]
for c in K["classes"]: C.add_node(c)
for r, d in K["rels"].items():
    for s in d["src"]:
        for t in d["tgt"]:
            if s in K["classes"] and t in K["classes"] and s != t: C.add_edge(s, t)
cp = nx.spring_layout(C, k=0.9, iterations=300, seed=3)
json.dump({"inst": pos, "cls": {k: [round(float(v[0]) * 100, 2), round(float(v[1]) * 100, 2)] for k, v in cp.items()}}, open(out, "w"), separators=(",", ":"))
print("done", round(time.time() - t0, 1), "s")
