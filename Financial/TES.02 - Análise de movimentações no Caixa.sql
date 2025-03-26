SELECT
  C.cajo_number as Centro,
  C.POSTING_DATE AS Data_Lcto,
  CASE
    WHEN C.TRANSACT_TYPE = 'C' THEN 'Entrada Conta Bancária'
    WHEN C.TRANSACT_TYPE = 'B' THEN 'Saída Conta Bancária'
    WHEN C.TRANSACT_TYPE = 'R' THEN 'Receitas'
    WHEN C.TRANSACT_TYPE = 'E' THEN 'Despesas'
    WHEN C.TRANSACT_TYPE = 'D' THEN 'Lçto Cliente'
    WHEN C.TRANSACT_TYPE = 'K' THEN 'Lçto Fornecedor'
    ELSE 'Não Identificado'
  END Categoria,
  C.POSTING_NUMBER AS Documento,
  C.P_PAYMENTS AS Montante,
  C.POSITION_TEXT AS Texto
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_positions` AS C
WHERE
  C.CAJO_NUMBER IN ('1006', '1007') -- ESSE FILTRO SERVE PARA FILTRAR MAIS DE UM CENTRO
 -- C.CAJO_NUMBER = '2001' (ESSE FILTRO SERVE PARA FILTRAR APENAS UM CENTRO)
  AND C.POSTING_DATE BETWEEN '2025-01-01' AND '2025-03-12'
  AND C.POSITION_TEXT NOT LIKE '%estorno%'
ORDER BY
  C.cajo_number, C.POSTING_DATE
