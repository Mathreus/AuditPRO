SELECT 
  W.WERKS AS Centro,
  W.ERSDA AS Data_Criacao,
  W.KUNNR AS ID_Cliente,
  RIGHT(W.MATNR, 6) AS Codigo_Material,
  MAT.MAKTX AS Texto_Breve_Material,
  W.KULAB AS QTD
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_msku` AS W 
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS MAT 
	ON RIGHT(W.MATNR, 6) = RIGHT(MAT.MATNR, 6)
WHERE
  W.ERSDA BETWEEN '2025-01-01' AND '2025-05-31'
  AND W.KULAB <> 0
