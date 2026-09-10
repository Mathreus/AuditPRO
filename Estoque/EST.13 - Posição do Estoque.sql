SELECT DISTINCT
  POS.WERKS AS Centro,
  POS.LGORT AS Deposito,
  RIGHT(POS.MATNR, 6) AS Material,
  TEX.MAKTX AS Texto_Breve_Material,
  POS.LABST AS Utilizacao_Livre,
  COALESCE(SAFE_CAST(VLR.SALK3 AS NUMERIC), 0) AS Valor_Utilizacao,
  COALESCE(SAFE_CAST(VLR.SPERW AS NUMERIC), 0) AS Valor_Bloqueado,
  (COALESCE(SAFE_CAST(VLR.SALK3 AS NUMERIC), 0) + COALESCE(SAFE_CAST(VLR.SPERW AS NUMERIC), 0)) AS Valor_Total,
  COALESCE(SAFE_CAST(VLR.VERPR AS NUMERIC), 0) AS Valor_Unitario
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard` AS POS
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` AS VLR ON
  POS.WERKS = VLR.BWKEY AND
  POS.MATNR = VLR.MATNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS TEX ON
  POS.MATNR = TEX.MATNR 
WHERE
--  POS.WERKS = '1002' AND
  POS.LGORT = 'DREV' AND
--  RIGHT(POS.MATNR, 6) = '101976' AND
  POS.LABST <> 0