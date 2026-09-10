SELECT * FROM (
SELECT DISTINCT 
	   V.ERDAT AS DATA_PEDIDO,
	   V.VBELN AS PEDIDO,
	   L.VBELN AS REMESSA,
	   L.MATNR AS MATERIAL,
	   L.LFIMG AS QUANTIDADE,
	   V.AUART_ANA AS TIPO_DE_ORDEM
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard` AS M 
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.eban` AS B ON 
  B.MANDT = M.MANDT AND 
  B.MATNR = M.MATNR AND 
  B.RESWK = M.WERKS
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbep` AS E ON 
  E.MANDT = M.MANDT AND 
  B.BSART = E.BSART AND
  B.BANFN = E.BANFN 
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS V ON 
  V.MANDT = M.MANDT AND 
  V.MATNR = M.MATNR AND 
  E.VBELN = V.VBELN AND 
  E.POSNR = V.POSNR AND 
  V.WERKS = B.WERKS AND 
  V.AUART_ANA = 'ZCAS' AND 
  V.ABGRU = ''
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS K ON 
  K.MANDT = M.MANDT AND 
  K.VBELN = V.VBELN AND 
  K.LIFSK = ''
LEFT  JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS F ON 
  F.MANDT = M.MANDT AND 
  F.VBELV = V.VBELN AND 
  F.POSNV = V.POSNR AND 
  F.VBTYP_N = 'J'       
LEFT  JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS L ON 
  L.MANDT = M.MANDT AND 
  L.MATNR = M.MATNR AND 
  L.WERKS = V.WERKS AND 
  L.VBELN = F.VBELN  AND 
  L.POSNR = F.POSNN
WHERE 
  M.MANDT = '300')A 
WHERE 
  REMESSA IS NULL OR REMESSA = ''
ORDER BY 
  DATA_PEDIDO