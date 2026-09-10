WITH base_pagamentos AS (
  SELECT DISTINCT 
    B.BUKRS as Centro,
    B.LIFNR as ID_Fornecedor, 
    F.NAME1 as Fornecedor, 
    EXTRACT(YEAR FROM B.H_BUDAT) AS Ano,
    B.H_BUDAT as DT_Lancamento,
    B.AUGCP as Data_Compensacao,   
    B.AUGBL AS Doc_Compensado,
    BK.USNAM AS Usuario,
    B.DMBTR as Montante,
    B.SGTXT as Texto,
    -- Chave para identificar duplicidades (ajuste conforme necessidade)
    CONCAT(B.LIFNR, '|', CAST(B.DMBTR AS STRING), '|', B.BELNR) AS chave_duplicidade
  FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B
  INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS F 
    ON B.LIFNR = F.LIFNR
  INNER JOIN  
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` AS BK
    ON B.BUKRS = BK.BUKRS
    AND B.BELNR = BK.BELNR
    AND B.GJAHR = BK.GJAHR
  WHERE 
    B.LIFNR > '1000000000' 
    AND B.SHKZG = 'S'
    AND B.HKONT = '2010101003'
    AND B.AUGCP BETWEEN '2025-01-01' AND '2025-04-30'
),

contagem_duplicados AS (
  SELECT
    chave_duplicidade,
    COUNT(*) as qtd_ocorrencias
  FROM
    base_pagamentos
  GROUP BY
    chave_duplicidade
  HAVING
    COUNT(*) > 1
)

SELECT
  p.Centro,
  p.ID_Fornecedor,
  p.Fornecedor,
  p.Ano,
  p.DT_Lancamento,
  p.Data_Compensacao,
  p.Doc_Compensado,
  'Débito' AS Debito_Credito,
  p.Usuario,
  p.Montante,
  p.Texto,
  c.qtd_ocorrencias,
  'Possível duplicidade' AS status_analise
FROM
  base_pagamentos p
JOIN
  contagem_duplicados c
  ON p.chave_duplicidade = c.chave_duplicidade
WHERE
  p.Doc_Compensado NOT LIKE '%9120%'
ORDER BY
  p.ID_Fornecedor,
  p.Montante DESC,
  p.DT_Lancamento
