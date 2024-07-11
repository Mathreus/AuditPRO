SELECT DISTINCT
  B.BUKRS as CENTRO,
  B.BUPLA as LOCAL_NEG,
  B.LIFNR as COD_FORNECEDOR,
  LF.NAME1 as NOME_FORNC,
  B.BELNR as NUM_DOCUMENTO,
  B.H_BUDAT as DT_LACAMENTO,
  DATE_DIFF(CURRENT_DATE(),B.H_BUDAT, DAY) as DIF_DT,
  B.DMBTR as MONTANTE,
  B.SGTXT as TEXTO
FROM
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg as B
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1 as LF ON
  B.MANDT = LF.MANDT AND 
  B.LIFNR = LF.LIFNR  
WHERE
  B.MANDT= '300' AND
  B.LIFNR > '1000000000' AND
  DATE_DIFF(CURRENT_DATE(), B.H_BUDAT, DAY) > 120 AND
  B.AUGBL = '' AND
  B.HKONT = '1010301003'