SELECT
  FF.CAJO_NUMBER AS Centro,
  FF.POSTING_DATE AS Data_Lcto,
  SEG.AUGCP AS Data_Compensacao,
  FF.POSTING_NUMBER AS Documento,
  SEG.BELNR AS Lcto,
  SEG.AUGBL AS DocCompensacao,
  CASE
    WHEN FF.TRANSACT_TYPE = 'C' THEN 'Entrada caixa de Conta Bancária'
    WHEN FF.TRANSACT_TYPE = 'B' THEN 'Saida caixa de Conta Bancária'
    WHEN FF.TRANSACT_TYPE = 'R' THEN 'Receitas'
    WHEN FF.TRANSACT_TYPE = 'E' THEN 'Despesas'
    WHEN FF.TRANSACT_TYPE = 'D' THEN 'Lancamento Cliente'
    WHEN FF.TRANSACT_TYPE = 'K' THEN 'Lancamento Fornecedor'
    ELSE 'Nada'
  END Transacao,
--  FF.TRANSACT_NUMBER AS Tipo_Transacao,
  FF.VENDOR_NO AS Cod_Fornecedor,
  FNC.NAME1 AS Fornecedor,
  FF.P_PAYMENTS AS Montante,
  FF.POSITION_TEXT AS Texto
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_positions` AS FF
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_documents` AS TDOC
  ON FF.CAJO_NUMBER = TDOC.CAJO_NUMBER
  AND FF.POSTING_DATE = TDOC.POSTING_DATE
  AND FF.POSTING_NUMBER = TDOC.POSTING_NUMBER
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS SEG
  ON FF.COMP_CODE = SEG.BUKRS
  AND FF.GL_ACCOUNT = SEG.HKONT
  AND FF.POSTING_DATE = SEG.H_BUDAT
  AND FF.P_PAYMENTS = SEG.DMBTR
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` AS BK
  ON SEG.BELNR = BK.BELNR
  AND SEG.BUKRS = BK.BUKRS
  AND SEG.H_BUDAT = BK.BUDAT
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS FNC
  ON FF.VENDOR_NO = FNC.LIFNR
WHERE
  FF.POSTING_DATE BETWEEN '2025-06-01' AND '2025-06-30'
  AND FF.POSITION_TEXT LIKE '%RPA%'
