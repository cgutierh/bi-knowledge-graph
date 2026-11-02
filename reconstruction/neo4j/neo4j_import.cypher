// Neo4j import for the original CSV export.
// Copy the csv/ folder into Neo4j's import/ directory, then run this script (e.g. cypher-shell -f neo4j_import.cypher).
// Every node also gets the :KGNode label so relationship files with mixed endpoint labels can be matched on id.
CREATE CONSTRAINT kgnode_id IF NOT EXISTS FOR (n:KGNode) REQUIRE n.id IS UNIQUE;

// boehringer-ingelheim :: Brand
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/Brand.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Brand`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`name` = row.`name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: Chunk
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/Chunk.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Chunk`,
    n.`graphScope` = row.`graphScope`,
    n.`chunk_id` = row.`chunk_id`,
    n.`chunk_index` = toInteger(row.`chunk_index`),
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_hash` = row.`source_hash`,
    n.`text` = row.`text`,
    n.`token_count` = toInteger(row.`token_count`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: Document
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/Document.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Document`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`file_name` = row.`file_name`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`status` = row.`status`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: Section
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/Section.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Section`,
    n.`graphScope` = row.`graphScope`,
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`section_title` = row.`section_title`,
    n.`section_type` = row.`section_type`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`text` = row.`text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: ToneRule
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/ToneRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ToneRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: VisualRule
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/nodes/VisualRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`VisualRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'boehringer-ingelheim' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Brand
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Brand.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Brand`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`name` = row.`name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: CardiovascularOutcome
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/CardiovascularOutcome.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`CardiovascularOutcome`,
    n.`graphScope` = row.`graphScope`,
    n.`outcome_text` = row.`outcome_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Chunk
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Chunk.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Chunk`,
    n.`graphScope` = row.`graphScope`,
    n.`chunk_id` = row.`chunk_id`,
    n.`chunk_index` = toInteger(row.`chunk_index`),
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_hash` = row.`source_hash`,
    n.`text` = row.`text`,
    n.`token_count` = toInteger(row.`token_count`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Claim
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Claim.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Claim`,
    n.`graphScope` = row.`graphScope`,
    n.`approval_status` = row.`approval_status`,
    n.`audience` = row.`audience`,
    n.`brand` = row.`brand`,
    n.`claim_status` = row.`claim_status`,
    n.`claim_text` = row.`claim_text`,
    n.`indication` = row.`indication`,
    n.`key_message_type` = row.`key_message_type`,
    n.`market` = row.`market`,
    n.`row_number` = toInteger(row.`row_number`),
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_status` = row.`source_status`,
    n.`table_id` = row.`table_id`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: ClinicalTrial
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/ClinicalTrial.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ClinicalTrial`,
    n.`graphScope` = row.`graphScope`,
    n.`nct_number` = row.`nct_number`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.`trial_name` = row.`trial_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: ContentModule
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/ContentModule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ContentModule`,
    n.`graphScope` = row.`graphScope`,
    n.`module_name` = row.`module_name`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`table_id` = row.`table_id`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Document
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Document.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Document`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`file_name` = row.`file_name`,
    n.`market` = row.`market`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`status` = row.`status`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Indication
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Indication.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Indication`,
    n.`graphScope` = row.`graphScope`,
    n.`indication_text` = row.`indication_text`,
    n.`market` = row.`market`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Market
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Market.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Market`,
    n.`graphScope` = row.`graphScope`,
    n.`name` = row.`name`,
    n.`region` = row.`region`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: PISection
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/PISection.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`PISection`,
    n.`graphScope` = row.`graphScope`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`section_title` = row.`section_title`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`text` = row.`text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Reference
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Reference.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Reference`,
    n.`graphScope` = row.`graphScope`,
    n.`reference_text` = row.`reference_text`,
    n.`row_number` = toInteger(row.`row_number`),
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`table_id` = row.`table_id`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: RenalOutcome
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/RenalOutcome.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`RenalOutcome`,
    n.`graphScope` = row.`graphScope`,
    n.`outcome_text` = row.`outcome_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: SafetyStatement
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/SafetyStatement.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`SafetyStatement`,
    n.`graphScope` = row.`graphScope`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`statement_text` = row.`statement_text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Section
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Section.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Section`,
    n.`graphScope` = row.`graphScope`,
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`section_title` = row.`section_title`,
    n.`section_type` = row.`section_type`,
    n.`sheet_name` = row.`sheet_name`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`text` = row.`text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: Table
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/Table.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Table`,
    n.`graphScope` = row.`graphScope`,
    n.`data` = row.`data`,
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`sheet_name` = row.`sheet_name`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`table_id` = row.`table_id`,
    n.`table_index` = toInteger(row.`table_index`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: ToneRule
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/ToneRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ToneRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: VisualRule
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/nodes/VisualRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`VisualRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'jardiance' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Brand
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Brand.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Brand`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`name` = row.`name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Chunk
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Chunk.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Chunk`,
    n.`graphScope` = row.`graphScope`,
    n.`chunk_id` = row.`chunk_id`,
    n.`chunk_index` = toInteger(row.`chunk_index`),
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_hash` = row.`source_hash`,
    n.`text` = row.`text`,
    n.`token_count` = toInteger(row.`token_count`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: ClinicalTrial
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/ClinicalTrial.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ClinicalTrial`,
    n.`graphScope` = row.`graphScope`,
    n.`nct_number` = row.`nct_number`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.`trial_name` = row.`trial_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Document
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Document.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Document`,
    n.`graphScope` = row.`graphScope`,
    n.`brand_id` = row.`brand_id`,
    n.`file_name` = row.`file_name`,
    n.`market` = row.`market`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`status` = row.`status`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Indication
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Indication.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Indication`,
    n.`graphScope` = row.`graphScope`,
    n.`indication_text` = row.`indication_text`,
    n.`market` = row.`market`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Market
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Market.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Market`,
    n.`graphScope` = row.`graphScope`,
    n.`name` = row.`name`,
    n.`region` = row.`region`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: PISection
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/PISection.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`PISection`,
    n.`graphScope` = row.`graphScope`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`section_title` = row.`section_title`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`text` = row.`text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: RespiratoryOutcome
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/RespiratoryOutcome.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`RespiratoryOutcome`,
    n.`graphScope` = row.`graphScope`,
    n.`outcome_text` = row.`outcome_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`source_page` = toInteger(row.`source_page`),
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: SafetyStatement
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/SafetyStatement.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`SafetyStatement`,
    n.`graphScope` = row.`graphScope`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`population` = row.`population`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`statement_text` = row.`statement_text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: Section
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/Section.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`Section`,
    n.`graphScope` = row.`graphScope`,
    n.`extraction_method` = row.`extraction_method`,
    n.`page_number` = toInteger(row.`page_number`),
    n.`section_id` = row.`section_id`,
    n.`section_title` = row.`section_title`,
    n.`section_type` = row.`section_type`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.`text` = row.`text`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: ToneRule
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/ToneRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`ToneRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: VisualRule
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/nodes/VisualRule.csv' AS row
CALL { WITH row
  MERGE (n:KGNode {id: row.id}) SET n:`VisualRule`,
    n.`graphScope` = row.`graphScope`,
    n.`rule_text` = row.`rule_text`,
    n.`section_id` = row.`section_id`,
    n.`source_document_id` = row.`source_document_id`,
    n.`source_document_type` = row.`source_document_type`,
    n.`source_file_name` = row.`source_file_name`,
    n.kg = CASE row.graphScope WHEN 'enterprise' THEN 'enterprise' ELSE 'ofev' END
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: BRAND_HAS_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/BRAND_HAS_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: BRAND_HAS_TONE_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/BRAND_HAS_TONE_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_TONE_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: BRAND_HAS_VISUAL_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/BRAND_HAS_VISUAL_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_VISUAL_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: DERIVED_FROM_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/DERIVED_FROM_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: DERIVED_FROM_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/DERIVED_FROM_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: DOCUMENT_HAS_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/DOCUMENT_HAS_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DOCUMENT_HAS_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// boehringer-ingelheim :: SECTION_HAS_CHUNK
LOAD CSV WITH HEADERS FROM 'file:///csv/boehringer-ingelheim/relationships/SECTION_HAS_CHUNK.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`SECTION_HAS_CHUNK`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: BRAND_HAS_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/BRAND_HAS_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: BRAND_HAS_TONE_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/BRAND_HAS_TONE_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_TONE_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: BRAND_HAS_VISUAL_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/BRAND_HAS_VISUAL_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_VISUAL_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: BRAND_TARGETS_MARKET
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/BRAND_TARGETS_MARKET.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_TARGETS_MARKET`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: CLAIM_DERIVED_FROM_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/CLAIM_DERIVED_FROM_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`CLAIM_DERIVED_FROM_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: CLAIM_SUPPORTED_BY_REFERENCE
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/CLAIM_SUPPORTED_BY_REFERENCE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`CLAIM_SUPPORTED_BY_REFERENCE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: CONTENT_MODULE_CONTAINS_CLAIM
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/CONTENT_MODULE_CONTAINS_CLAIM.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`CONTENT_MODULE_CONTAINS_CLAIM`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: DERIVED_FROM_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/DERIVED_FROM_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: DERIVED_FROM_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/DERIVED_FROM_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: DERIVED_FROM_TABLE
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/DERIVED_FROM_TABLE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_TABLE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: DOCUMENT_HAS_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/DOCUMENT_HAS_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DOCUMENT_HAS_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: DOCUMENT_HAS_TABLE
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/DOCUMENT_HAS_TABLE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DOCUMENT_HAS_TABLE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: MARKET_PART_OF_REGION
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/MARKET_PART_OF_REGION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`MARKET_PART_OF_REGION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: OUTCOME_FROM_TRIAL
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/OUTCOME_FROM_TRIAL.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`OUTCOME_FROM_TRIAL`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: PI_SECTION_CONTAINS_SAFETY
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/PI_SECTION_CONTAINS_SAFETY.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`PI_SECTION_CONTAINS_SAFETY`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: RENAL_OUTCOME_FROM_TRIAL
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/RENAL_OUTCOME_FROM_TRIAL.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`RENAL_OUTCOME_FROM_TRIAL`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// jardiance :: SECTION_HAS_CHUNK
LOAD CSV WITH HEADERS FROM 'file:///csv/jardiance/relationships/SECTION_HAS_CHUNK.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`SECTION_HAS_CHUNK`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: BRAND_HAS_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/BRAND_HAS_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: BRAND_HAS_TONE_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/BRAND_HAS_TONE_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_TONE_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: BRAND_HAS_VISUAL_RULE
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/BRAND_HAS_VISUAL_RULE.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_HAS_VISUAL_RULE`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: BRAND_TARGETS_MARKET
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/BRAND_TARGETS_MARKET.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`BRAND_TARGETS_MARKET`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: DERIVED_FROM_DOCUMENT
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/DERIVED_FROM_DOCUMENT.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_DOCUMENT`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: DERIVED_FROM_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/DERIVED_FROM_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DERIVED_FROM_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: DOCUMENT_HAS_SECTION
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/DOCUMENT_HAS_SECTION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`DOCUMENT_HAS_SECTION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: MARKET_PART_OF_REGION
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/MARKET_PART_OF_REGION.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`MARKET_PART_OF_REGION`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: OUTCOME_FROM_TRIAL
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/OUTCOME_FROM_TRIAL.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`OUTCOME_FROM_TRIAL`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: PI_SECTION_CONTAINS_SAFETY
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/PI_SECTION_CONTAINS_SAFETY.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`PI_SECTION_CONTAINS_SAFETY`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;

// ofev :: SECTION_HAS_CHUNK
LOAD CSV WITH HEADERS FROM 'file:///csv/ofev/relationships/SECTION_HAS_CHUNK.csv' AS row
CALL { WITH row
  MATCH (a:KGNode {id: row.source_id}), (z:KGNode {id: row.target_id})
  MERGE (a)-[:`SECTION_HAS_CHUNK`]->(z)
} IN TRANSACTIONS OF 1000 ROWS;
