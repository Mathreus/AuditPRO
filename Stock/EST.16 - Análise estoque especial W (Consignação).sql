SELECT 
  W.WERKS AS Centro,
  W.ERSDA AS Data_Criacao,
  W.KUNNR AS ID_Cliente,
  W.MATNR AS Codigo_Material,
  W.MAKTX AS Texto_Breve_Material,
  W.KULAB AS QTD
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.msku` AS W -- Inclusão da tabela solicitada para Washington
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS MAT 
	ON est.mandt = mat.mandt
	AND RIGHT(EST.MATNR, 6) = RIGHT(MAT.MATNR, 6)
WHERE
  W.ERSDA BETWEEN '2025-01-01' AND '2025-05-31'