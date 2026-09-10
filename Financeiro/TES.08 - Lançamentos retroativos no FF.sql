SELECT DISTINCT
  FF.COMP_CODE AS Empresa,
  FF.CAJO_NUMBER AS Centro,
  FF.POSTING_DATE AS Data_Lcto,
  SIS.VALUT AS Data_Criacao,
  DATE_DIFF(SIS.VALUT, FF.POSTING_DATE, DAY) AS DIF,
  FF.POSTING_NUMBER AS Documento,
  SIS.BELNR AS Numero_Documento,
  CASE
    WHEN FF.TRANSACT_TYPE = 'C' THEN 'Entrada caixa de Conta Bancaria'
    WHEN FF.TRANSACT_TYPE = 'B' THEN 'Saida caixa de Conta Bancaria'
    WHEN FF.TRANSACT_TYPE = 'R' THEN 'Receitas'
    WHEN FF.TRANSACT_TYPE = 'E' THEN 'Despesas'
    WHEN FF.TRANSACT_TYPE = 'D' THEN 'Lancamento Cliente'
    WHEN FF.TRANSACT_TYPE = 'K' THEN 'Lancamento Fornecedor'
    ELSE 'Nada'
  END Transacao,
  BK.USNAM AS Usuario,
  FF.GL_ACCOUNT AS Conta_Contabil,
  ST.TXT50 AS Descricao_Conta_Contabil,
  FF.P_PAYMENTS AS Montante,
  FF.POSITION_TEXT AS Texto
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_positions` AS FF
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsis` AS SIS
  ON FF.COMP_CODE = SIS.BUKRS
  AND FF.GL_ACCOUNT = SIS.HKONT
  AND FF.POSTING_DATE = SIS.BUDAT
  AND FF.P_PAYMENTS = SIS.DMBTR
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` AS BK
  ON SIS.BELNR = BK.BELNR
  AND SIS.BUKRS = BK.BUKRS
  AND SIS.BUDAT = BK.BUDAT
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS ST
  ON FF.GL_ACCOUNT = ST.SAKNR
WHERE
  FF.POSTING_DATE BETWEEN '2025-01-01' AND '2025-06-30'
  AND SIS.AUGBL = ''
ORDER BY
  FF.CAJO_NUMBER, FF.POSTING_DATE ASC