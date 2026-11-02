# BI Knowledge Graph

Reconstrucción semántica e interfaz web del grafo de conocimiento de Boehringer Ingelheim exportado el 29‑sep‑2026. Contiene tres grafos de marca, **Life Forward** (BI corporativo), **Jardiance** y **OFEV**, con 4.912 nodos y 7.599 relaciones trazables hasta documento, sección y página.

> ⚠️ Contiene material interno: hojas de claims (incluidos claims candidatos sin aprobar) y guías de marca. El repositorio es privado. Si GitHub Pages está activado, la web es **pública** para cualquiera que tenga la URL.

## Web

| Página | Qué es |
|---|---|
| `index.html` | Explorador: búsqueda (texto, `"frase exacta"`, `campo:valor`), fichas de nodo con procedencia y vecindario, consultas SPARQL en el navegador (Oxigraph WASM) y esquema |
| `auditoria.html` | Diagnóstico del export: hallazgos de calidad, mapa ontología–datos y grafo de negocio |
| `readme.html` | Documentación completa |

Para usarla en local hay que servirla por HTTP: `python3 -m http.server 8000` y abrir http://localhost:8000.

## Estructura

```
index.html, auditoria.html, readme.html   páginas web
data/        kg.json (explorador), kg.trig (dataset RDF), ontology.ttl
vendor/      oxigraph_bg.wasm (motor SPARQL Oxigraph 0.5.11, MIT/Apache-2.0)
reconstruction/
  ontology/    bi_kg_ontology.ttl (OWL) · shapes_<marca>.ttl (SHACL)
  rdf/         bi_kg_all.trig · <marca>.ttl · enterprise.ttl
  jsonld/      <marca>.graph.jsonld (JSON-LD original corregido)
  graphml/     bi_kg_all.graphml (Gephi, yEd, Cytoscape)
  neo4j/       neo4j_import.cypher (LOAD CSV; no probado contra Neo4j)
  validation/  shacl_summary.json
  scripts/     build.py · validate.py · explorer_data.py · webdata.py
```

## Regenerar

```
pip install rdflib pyshacl networkx
python3 reconstruction/scripts/build.py <BI_Knowledge_Graph_Export> out
python3 reconstruction/scripts/validate.py <BI_Knowledge_Graph_Export> out
python3 reconstruction/scripts/webdata.py <BI_Knowledge_Graph_Export> data
cp out/rdf/bi_kg_all.trig data/kg.trig && cp out/ontology/bi_kg_ontology.ttl data/ontology.ttl
```

## Hallazgos principales

- La estructura es íntegra: no hay aristas colgantes ni nodos aislados, y los CSV y el JSON-LD coinciden 1:1.
- **112 claims de eficacia de Jardiance (62 aprobados) no tienen `CLAIM_REQUIRES_SAFETY`**, aunque la ontología lo exige.
- Muchas clases de la ontología no tienen instancias: Product, Audience, Channel, ComplianceRule…
- Solo hay mercado EE. UU., aunque existen documentos EPAR de la UE.
- Hay errores de extracción en algunos resultados clínicos, y la mayoría de las reglas de tono y visuales son encabezados de sección.
