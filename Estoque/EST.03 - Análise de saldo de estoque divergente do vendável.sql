SELECT DISTINCT
  MB.BWKEY AS Centro,
  POS.LGORT AS Deposito,
  RIGHT(MB.MATNR, 6) AS Material,
  TEX.MAKTX AS Texto_Breve_Material,
--  M.MATKL AS Grupo_Mercadorias,
--  MB.LBKUM AS QTD,
--  MB.SALK3 AS Montante,
--  POS.LABST AS Utilizacao_Livre,
--  (POS.LABST * MB.VERPR) AS Val_utiliz_livre,
--  POS.SPEME AS Bloqueado,
--  (POS.SPEME * MB.VERPR) AS Val_estoque_bloq,
  (POS.LABST + POS.SPEME) AS Quantidade,
--  MB.VERPR AS Preco_Unitario,
  ((POS.LABST + POS.SPEME) * MB.VERPR ) AS Valor_Estoque
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` AS MB
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS TEX ON
  MB.MATNR = TEX.MATNR 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard` AS POS ON
  MB.BWKEY = POS.WERKS 
  AND MB.MATNR = POS.MATNR
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.mara` as M ON
  MB.MATNR = M.MATNR 
WHERE
  POS.LGORT NOT IN ('DREV', 'DUSO', 'ALMX')
  AND (POS.LABST + POS.SPEME) <> 0
ORDER BY 
  MB.BWKEY ASC