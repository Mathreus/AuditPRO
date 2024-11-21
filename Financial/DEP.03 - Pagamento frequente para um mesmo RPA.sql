SELECT
  FF.CAJO_NUMBER AS Centro,
  FF.POSTING_DATE AS Data_Lcto,
  FF.POSTING_NUMBER AS Documento,
  CASE
    WHEN FF.TRANSACT_TYPE = 'C' THEN 'Entrada caixa de Conta Bancária'
    WHEN FF.TRANSACT_TYPE = 'B' THEN 'Saída caixa de Conta Bancária'
    WHEN FF.TRANSACT_TYPE = 'R' THEN 'Receitas'
    WHEN FF.TRANSACT_TYPE = 'E' THEN 'Despesas'
    WHEN FF.TRANSACT_TYPE = 'D' THEN 'Lançamento Cliente'
    WHEN FF.TRANSACT_TYPE = 'K' THEN 'Lançamento Fornecedor'
    ELSE 'Nada'
  END Transacao,
  FF.P_PAYMENTS AS Montante,
  FF.POSITION_TEXT AS Texto
FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_positions` as FF
WHERE
  FF.POSTING_DATE BETWEEN '2024-01-01' AND '2024-11-20'