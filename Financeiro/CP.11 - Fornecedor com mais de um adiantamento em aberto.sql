SELECT 
  ADT.BUKRS AS COD_EMPRESA,
  ADT.EMPRESA,
  ADT.LIFNR AS COD_FORNECEDOR,
  ADT.NAME1 AS FORNECEDOR,
  ADT.BELNR AS DOC,
  ADT.BUZEI AS ITEM_DOC,
  ADT.DMBTR AS VALOR_DOC,
  ADT.ZFBDT AS DT_BASE,
  ADT.NETDT AS DT_VENCIMENTO,
  ADT.DT_CORTE,
  ADT.DIAS_ABERTO
FROM
  (
    SELECT
      ADT.BUKRS,
      EMP.BUTXT AS EMPRESA,
      ADT.LIFNR,
      FORN.NAME1,
      ADT.BELNR,
      ADT.BUZEI,
      ADT.DMBTR,
      ADT.ZFBDT,
      ADT.NETDT,
      '31/10/2024' AS DT_CORTE,
      DATE_DIFF('2024-11-01', ADT.ZFBDT, DAY) AS DIAS_ABERTO,
      COUNT(*) OVER(PARTITION BY ADT.BUKRS , ADT.LIFNR ) AS CONTAGEM
    FROM
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as ADT
    INNER JOIN 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as PG
          ON ADT.BUKRS = PG.BUKRS 
          AND PG.SHKZG = 'H' 
          AND ADT.BELNR = PG.BELNR 
          AND PG.HKONT LIKE '10101026%' 
          AND ADT.GJAHR = PG.GJAHR
    INNER JOIN 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001` as EMP ON EMP.BUKRS = ADT.BUKRS
    INNER JOIN 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as FORN ON FORN.LIFNR = ADT.LIFNR
    WHERE
      ADT.MANDT = '300' 
      AND ADT.LIFNR > '1000000000' AND 
--      DATE_DIFF(CURRENT_DATE(), ADT.H_BUDAT, DAY) > 30 AND
      (ADT.AUGBL = '' OR ADT.AUGCP > '2024-10-31' ) 
      AND ADT.HKONT = '1010301001'
      AND ADT.SHKZG = 'S'
      AND ADT.ZFBDT < '2024-11-01'
  ) AS ADT
WHERE
  ADT.CONTAGEM > 1