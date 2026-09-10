WITH
  SUB1 AS (
    SELECT DISTINCT
      B.BUKRS AS CENTRO_ADT,
      B.LIFNR AS COD_FORNECEDOR_ADT, 
      CAF.NAME1 AS NOME_FORNECEDOR_ADT,
      MIN(B.H_BUDAT) AS DT_LANCAMENTO_ADT,
      SUM(B.DMBTR) AS MONTANTE_ADT
    FROM 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B
    INNER JOIN 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS CP 
      ON B.BUKRS = CP.BUKRS 
      AND CP.SHKZG = 'H' 
      AND B.BELNR = CP.BELNR 
      AND CP.HKONT LIKE '10101026%' 
      AND B.GJAHR = CP.GJAHR
    INNER JOIN 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS CAF 
      ON B.MANDT = CAF.MANDT 
      AND B.LIFNR = CAF.LIFNR
    WHERE 
      B.MANDT = '300' 
      AND B.LIFNR LIKE '1000%' 
      AND DATE_DIFF('2024-11-01', B.H_BUDAT, DAY) > 30 
      AND B.AUGBL = '' 
      AND B.HKONT IN ('1010301001', '1010301002', '1010301003', '1010701004', '1010301004')
      AND B.SHKZG = 'S'
    GROUP BY 
      B.BUKRS,
      B.BUPLA,
      B.LIFNR,
      CAF.NAME1
  ),
  SUB2 AS (
SELECT DISTINCT
      FORN.BUKRS AS FORN_PG,
      ADT.LIFNR AS COD_FORN,
      SUM(FORN.DMBTR) AS VLR_FORN
    FROM
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS FORN
    INNER JOIN
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS ADT ON
         FORN.BELNR = ADT.BELNR
         AND FORN.GJAHR = ADT.GJAHR 
    WHERE
     FORN.AUGDT BETWEEN '2024-11-01' AND '2024-11-30'
      AND FORN.SHKZG = 'H'
      AND FORN.HKONT LIKE '10101026%'
    GROUP BY
      ADT.LIFNR,
      FORN.BUKRS
  )

SELECT
  SUB1.CENTRO_ADT,
  SUB1.COD_FORNECEDOR_ADT,
  SUB1.NOME_FORNECEDOR_ADT,
  SUB1.DT_LANCAMENTO_ADT,
  SUM(SUB1.MONTANTE_ADT) AS MONTANTE_ADT,
  SUM(SUB2.VLR_FORN) AS MONTANTE_PAGO
FROM SUB1
JOIN SUB2 
  ON SUB1.COD_FORNECEDOR_ADT = SUB2.COD_FORN
  AND SUB2.FORN_PG = SUB1.CENTRO_ADT
GROUP BY 
  SUB1.CENTRO_ADT,
  SUB1.COD_FORNECEDOR_ADT,
  SUB1.NOME_FORNECEDOR_ADT,
  SUB1.DT_LANCAMENTO_ADT