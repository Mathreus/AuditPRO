-- Não finalizado

SELECT DISTINCT
  POS.WERKS AS Centro,
  POS.LGORT AS Deposito,
  RIGHT(POS.MATNR, 6) AS Material,
  TEX.MAKTX AS Texto_Breve_Material,
  POS.LABST AS Utilizacao_Livre,
  VLR.SALK3 AS Valor_Total
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard` AS POS
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` as VLR ON
  POS.WERKS = VLR.BWKEY AND
  POS.MATNR = VLR.MATNR AND
  VLR.BWTAR = 'COMERC_C/I'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS TEX ON
  POS.MATNR = TEX.MATNR 
WHERE
  POS.WERKS = '1002'
  AND POS.LGORT = 'DREV'
  AND RIGHT(POS.MATNR, 6) = '105372'