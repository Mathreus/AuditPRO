SELECT
  C.CAJO_NUMBER AS Centro,
  C.POSTING_DATE AS Data_Lcto,

  CASE
    WHEN C.TRANSACT_TYPE = 'C' THEN 'Entrada Conta Bancária'
    WHEN C.TRANSACT_TYPE = 'B' THEN 'Saída Conta Bancária'
    WHEN C.TRANSACT_TYPE = 'R' THEN 'Receitas'
    WHEN C.TRANSACT_TYPE = 'E' THEN 'Despesas'
    WHEN C.TRANSACT_TYPE = 'D' THEN 'Lançamento Cliente'
    WHEN C.TRANSACT_TYPE = 'K' THEN 'Lançamento Fornecedor'
    ELSE 'Não Identificado'
  END AS Categoria,

  C.POSTING_NUMBER AS Documento,
  DOC.BP_NAME AS Nome_Fornecedor,
  C.P_PAYMENTS AS Montante,
  C.POSITION_TEXT AS Texto,
  DOC.REVBELNR AS Estorno

FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_positions` AS C

LEFT JOIN `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_documents` AS DOC
  ON C.COMP_CODE = DOC.COMP_CODE
  AND C.POSTING_NUMBER = DOC.POSTING_NUMBER

WHERE
  C.CAJO_NUMBER  IN ('2016', '2036')
  AND DATE(C.POSTING_DATE) BETWEEN DATE '2026-01-01' AND DATE '2026-07-22'
  AND COALESCE(DOC.REVBELNR, '') = ''
  AND REGEXP_CONTAINS(
    UPPER(COALESCE(C.POSITION_TEXT, '')),
    r'RPA|CHAPEIRO'
  )
  AND C.TRANSACT_TYPE = 'K'
  AND NOT REGEXP_CONTAINS(
    UPPER(COALESCE(C.POSITION_TEXT, '')),
    r'ESTORNO'
  )

ORDER BY
  C.CAJO_NUMBER,
  C.POSTING_DATE;
