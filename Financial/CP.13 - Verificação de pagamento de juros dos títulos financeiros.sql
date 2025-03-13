WITH titulos AS (
    SELECT
        B.BUKRS,            
        B.BELNR,            
        B.GJAHR,            
        B.HKONT,            
        B.DMBTR AS VALOR_TITULO,  -- Valor Original do Título
        B.H_BUDAT AS DATA_LCTO,  
        B.LIFNR AS ID_Fornecedor,
        B.SGTXT AS Texto 
    FROM 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B
    WHERE 
        B.HKONT LIKE '10101026%'   -- Código da conta de títulos a receber
),
juros AS (
    SELECT
        J.BUKRS,    
        J.BELNR,    
        J.GJAHR,    
        SUM(J.DMBTR) AS VALOR_JUROS
    FROM
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS J
    WHERE
      J.HKONT IN ('3040302001')  -- Código da conta de juros
    GROUP BY 
      J.BUKRS, J.BELNR, J.GJAHR
)
SELECT 
    t.BUKRS AS Empresa,
    t.DATA_LCTO AS Data_Lcto, 
    t.GJAHR AS Ano,
    t.ID_Fornecedor,  
    t.BELNR AS Documento_Contabil,
    t.VALOR_TITULO,
    COALESCE(j.VALOR_JUROS, 0) AS VALOR_JUROS,
    (t.VALOR_TITULO + COALESCE(j.VALOR_JUROS, 0)) AS VALOR_TOTAL_COM_JUROS,
    t.TEXTO
FROM titulos t
LEFT JOIN juros j
    ON t.BUKRS = j.BUKRS
    AND t.BELNR = j.BELNR
    AND t.GJAHR = j.GJAHR
WHERE 
    COALESCE(j.VALOR_JUROS, 0) <> 0
ORDER BY
    COALESCE(j.VALOR_JUROS, 0) DESC;