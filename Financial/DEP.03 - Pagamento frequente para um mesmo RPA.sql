SELECT
  FF.CAJO_NUMBER AS Centro,
  FF.POSTING_DATE AS Data_Lcto,
  FF.POSTING_NUMBER AS Documento,
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
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS FNC
  ON FF.VENDOR_NO = FNC.LIFNR
WHERE
  FF.POSTING_DATE BETWEEN '2025-06-01' AND '2025-06-30'
  AND FF.POSITION_TEXT LIKE '%RPA%'
