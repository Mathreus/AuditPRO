SELECT DISTINCT
  COMP.BUKRS AS COD_EMPRESA,
  t001.BUTXT AS EMPRESA,
  COMP.BUPLA AS LOC_NEG,
  COMP.HBKID AS BANCO_EMPRESA,
  COMP.KUNNR AS COD_CLIENTE,
  kna1.NAME1 as NOME_CLIENTE,
  COMP.BELNR AS DOC_LANCAMENTO,
  COMP.BUZEI AS ITEM,
  COMP.AUGBL AS DOC_COMPENSACAO,
  COMP.H_BUDAT AS DT_LANCAMENTO,
  COMP.ZFBDT AS DT_BASE,
  CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
  END AS VENCIMENTO,
  COMP.AUGDT AS DT_COMPENSACAO,
  ( DATE_DIFF( COMP.AUGDT,
    CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END  , DAY) - 1) AS DIF_DT,
  SUM(COMP.DMBTR) AS VALOR_TIT_RECEBIDO,
  SUM(FIN.DMBTR) AS VLR_MULTA_E_JUROS_RECEBIDA,
  ROUND(COMP.DMBTR * 0.02,2) AS MULTA,
  ROUND(COMP.DMBTR * (0.05/30) * ( DATE_DIFF(COMP.AUGDT,
    CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END , DAY) -1 ) ,2) AS JUROS,
  ROUND(SUM(FIN.DMBTR) - ROUND(COMP.DMBTR * 0.02,2) - ROUND(COMP.DMBTR * (0.05/30) * ( DATE_DIFF(COMP.AUGDT,
    CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END , DAY) -1 ) ,2), 2)  AS DIFERENCA,
  bkpf.USNAM as USUARIO
FROM
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg AS COMP
LEFT JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg AS FIN 
    ON COMP.BUKRS = FIN.BUKRS 
    AND FIN.BELNR = COMP.AUGBL
--    AND FIN.BUZEI = COMP.BUZEI
    AND FIN.SHKZG = 'H'
--    AND FIN.BSCHL = '40'
    AND FIN.HKONT = '3040101012'
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg AS CP
    ON COMP.BUKRS = CP.BUKRS 
    AND CP.BELNR = COMP.AUGBL
--    AND CP.BUZEI = COMP.BUZEI
    AND CP.HKONT LIKE '101010%'
    AND CP.SHKZG = 'S'
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1 ON COMP.KUNNR = kna1.KUNNR
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf ON bkpf.AWKEY = fin.AWKEY
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.t001 ON t001.BUKRS = COMP.BUKRS
WHERE 
  COMP.H_BLART = 'RV' 
  AND COMP.HKONT = '1010201001'
  AND COMP.SHKZG = 'S'
  AND (CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END) < COMP.AUGDT
  AND COMP.AUGDT BETWEEN '2024-11-01' AND '2024-11-30'
  AND DATE_DIFF(  COMP.AUGDT, CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END , DAY) > 2
    AND COMP.KUNNR LIKE '1000%'
    AND COMP.ZLSCH = 'E'
GROUP BY
  COMP.BUKRS,
  COMP.BUPLA,
  COMP.ZFBDT,
  COMP.BUZEI,
  COMP.NETDT,
  COMP.KUNNR,
  COMP.BELNR,
  COMP.AUGBL,
  COMP.H_BUDAT,
  COMP.AUGDT,
  COMP.DMBTR,
  kna1.NAME1,
  bkpf.USNAM,
  t001.BUTXT,
  COMP.HBKID
  HAVING 
  ROUND(SUM(FIN.DMBTR) - ROUND(COMP.DMBTR * 0.02,2) - ROUND(COMP.DMBTR * (0.05/30) * ( DATE_DIFF(COMP.AUGDT,
    CASE 
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT ) = 7 THEN DATE_ADD(COMP.NETDT , INTERVAL 2 DAY)
    WHEN EXTRACT( DAYOFWEEK FROM COMP.NETDT) = 1 THEN DATE_ADD(COMP.NETDT , INTERVAL 1 DAY)
    ELSE COMP.NETDT
    END , DAY) -1 ) ,2), 2) < 0