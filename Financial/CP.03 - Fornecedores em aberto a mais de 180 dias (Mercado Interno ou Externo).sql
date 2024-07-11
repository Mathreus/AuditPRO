SELECT DISTINCT 
  B.BUKRS as EMPRESA,
  B.BUPLA as LOCAL_NEG,
  B.LIFNR as COD_FORNECEDOR, 
  CAF.NAME1 as NOME_FORNECEDOR, 
  B.BELNR as NUM_DOCUMENTO,
  B.H_BUDAT as DT_LACAMENTO,
  B.NETDT as VENCIMENTO,
  B.AUGCP as DATA_COMPENSACAO,  
  DATE_DIFF(CURRENT_DATE(),B.H_BUDAT, DAY) as DIF_DT, 
  B.SHKZG as D_C, 
  B.DMBTR as MONTANTE,
  B.SGTXT as TEXTO
FROM 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg as B
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1 as CAF 
  ON B.MANDT = CAF.MANDT AND B.LIFNR = CAF.LIFNR
WHERE 
  B.MANDT = '300' AND 
  B.LIFNR > '1000000000' AND 
  DATE_DIFF(CURRENT_DATE(), B.H_BUDAT, DAY) > 30 AND
  B.AUGBL = '' AND 
  B.HKONT = '1010301001'