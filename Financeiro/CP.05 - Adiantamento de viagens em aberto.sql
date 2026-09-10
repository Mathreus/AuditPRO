SELECT 
  F.BUKRS AS Empresa,
  F.LIFNR AS ID_Externo,
  FORN.NAME1 AS Fornecedores,
  F.BUDAT AS Data_Lcto,
  CURRENT_DATE() AS Hoje,
  DATE_DIFF(CURRENT_DATE(), F.BUDAT, DAY) AS Dias_Diferenca,
  F.BLART AS Lancamento,
  F.HKONT AS Conta_Razao,
  CASE
    WHEN F.SHKZG = 'S' THEN 'Débito'
    WHEN F.SHKZG = 'H' THEN 'Crédito'
    ELSE 'Falso'
  END AS Natureza,
  F.BELNR AS Documento,
  F.DMBTR AS Montante,
  F.SGTXT AS Referencia
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsik` AS F
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS FORN ON
  F.LIFNR = FORN.LIFNR
WHERE
  F.HKONT = '1010301001'
  AND F.SGTXT LIKE '%VIAGEM%'
  AND DATE_DIFF(CURRENT_DATE(), F.BUDAT, DAY) > 30