WITH RESUMO AS (
    SELECT
        B.BUKRS AS EMPRESA,
        B.LIFNR AS FORNECEDOR,
        L.NAME1 AS NOME_FORNECEDOR,

        ROUND(SUM(
            CASE 
                WHEN B.SHKZG = 'H' THEN -ABS(SAFE_CAST(B.DMBTR AS NUMERIC))
                ELSE 0
            END
        ), 2) AS CREDITO,

        ROUND(SUM(
            CASE 
                WHEN B.SHKZG = 'S' THEN ABS(SAFE_CAST(B.DMBTR AS NUMERIC))
                ELSE 0
            END
        ), 2) AS DEBITO,

        ROUND(SUM(
            CASE 
                WHEN B.SHKZG = 'H' THEN -ABS(SAFE_CAST(B.DMBTR AS NUMERIC))
                WHEN B.SHKZG = 'S' THEN ABS(SAFE_CAST(B.DMBTR AS NUMERIC))
                ELSE 0
            END
        ), 2) AS DIFERENCA

    FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsik` B

    LEFT JOIN `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` L
        ON B.MANDT = L.MANDT
       AND B.LIFNR = L.LIFNR

    WHERE B.LIFNR IS NOT NULL
      AND (
            B.AUGBL IS NULL
            OR TRIM(CAST(B.AUGBL AS STRING)) = ''
          )
      AND (
            (B.SHKZG = 'H' AND B.BLART IN ('KR', 'RE'))
         OR (B.SHKZG = 'S' AND B.BLART IN ('KG', 'KZ'))
          )

    GROUP BY
        B.BUKRS,
        B.LIFNR,
        L.NAME1
)

SELECT
    FORNECEDOR AS `Fornecedor`,
    NOME_FORNECEDOR AS `Nome do fornecedor`,
    CREDITO AS `Crédito`,
    DEBITO AS `Débito`,
    DIFERENCA AS `Diferença`

FROM RESUMO

WHERE CREDITO <> 0
  AND DEBITO <> 0

ORDER BY
    `Diferença` ASC;
