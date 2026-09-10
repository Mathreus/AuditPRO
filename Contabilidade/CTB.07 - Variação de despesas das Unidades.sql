SELECT * FROM `auditoria.vw_analise_despesas_unidade_mar_2026`

CREATE OR REPLACE VIEW production-servers-magnumtires.auditoria.vw_analise_despesas_unidade_mar_2026 AS

WITH base AS (
  SELECT
    DOCA.RBUKRS AS Empresa,
    LEFT(DOCA.PRCTR, 4) AS Centro,
    CAST(DOCA.RACCT AS STRING) AS Conta_Contabil,
    SK.TXT50 AS Texto,
    ABS(SUM(DOCA.TSL)) AS Montante
  FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.acdoca` AS DOCA
  LEFT JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.ska1` AS CC
    ON DOCA.RACCT = CC.SAKAN
  LEFT JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS SK
    ON CC.SAKNR = SK.SAKNR
  WHERE
    DOCA.RLDNR = '0L'
    AND DOCA.RBUKRS = '2000'
    AND DOCA.BUDAT BETWEEN '2026-02-01' AND '2026-02-28'
    AND DOCA.XTRUEREV = ''
    AND (
      CAST(DOCA.RACCT AS STRING) = '3010101001'
      OR REGEXP_CONTAINS(
        CAST(DOCA.RACCT AS STRING),
        r'^(303030|303040|303050|303060|303070|303080|303090)'
      )
    )
  GROUP BY
    Empresa,
    Centro,
    Conta_Contabil,
    Texto
),

receita AS (
  SELECT
    Empresa,
    Centro,
    SUM(Montante) AS Receita_Vendas
  FROM base
  WHERE Conta_Contabil = '3010101001'
  GROUP BY
    Empresa,
    Centro
),

despesas AS (
  SELECT
    Empresa,
    Centro,
    Conta_Contabil,
    Texto,
    SUM(Montante) AS Despesa
  FROM base
  WHERE REGEXP_CONTAINS(
    Conta_Contabil,
    r'^(303030|303040|303050|303060|303070|303080|303090)'
  )
  GROUP BY
    Empresa,
    Centro,
    Conta_Contabil,
    Texto
),

resultado AS (
  SELECT
    d.Empresa,
    d.Centro,
    d.Conta_Contabil,
    d.Texto,
    d.Despesa,
    r.Receita_Vendas,
    ROUND(SAFE_DIVIDE(d.Despesa, r.Receita_Vendas) * 100, 2) AS Percentual
  FROM despesas d
  LEFT JOIN receita r
    ON d.Empresa = r.Empresa
   AND d.Centro = r.Centro
)

SELECT
  Empresa,
  Centro,
  Conta_Contabil,
  Texto,
  Despesa,
  Receita_Vendas,
  Percentual,
  ROUND(AVG(Despesa) OVER (PARTITION BY Conta_Contabil), 2) AS Media_Despesa_Conta,
  ROUND(STDDEV(Percentual) OVER (PARTITION BY Conta_Contabil), 2) AS Desvio_Padrao_Percentual
FROM resultado
ORDER BY
  Centro,
  Conta_Contabil;
