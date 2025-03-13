SELECT DISTINCT 
    B.BUKRS as Centro,
    B.LIFNR as ID_Fornecedor, 
    F.NAME1 as Fornecedor, 
    EXTRACT(YEAR FROM B.H_BUDAT) AS Ano,
    B.H_BUDAT as DT_Lancamento,
    B.BELNR AS Documento,
    FORMAT_DATE('%d/%m/%Y', DATE_ADD(B.ZFBDT, INTERVAL CAST(B.ZBD1T AS INT64) DAY)) AS Data_Vencimento,
    FORMAT_DATE('%d/%m/%Y', CURRENT_DATE()) AS Data_Hoje,
    DATE_DIFF(CURRENT_DATE(), B.H_BUDAT, DAY) as Diferenca_Dias,
    CASE
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 0 THEN 'Antecipado'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 30 THEN '1 a 30 Dias' 
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 60 THEN '31 a 60 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 90 THEN '61 a 90 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 120 THEN '91 a 120 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 150 THEN '121 a 150 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 180 THEN '151 a 180 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 360 THEN '181 a 360 Dias'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 720 THEN '361 a 720 (1-2 anos)'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 1080 THEN '721 a 1080 (2-3 anos)'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 1440 THEN '1081 a 1440 (3-4 anos)'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 2160 THEN '1441 a 2160 (4-5 anos)'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 2520 THEN '2161 a 2520 (5-6 anos)'
      WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 2880 THEN '2521 a 2880 (6-7 anos)'
      ELSE 'A mais de 7 anos'
    END AS  Aging_List,
    B.AUGCP as Data_Compensacao,   
    CASE
      WHEN B.SHKZG = 'S' THEN 'Débito'
      WHEN B.SHKZG = 'H' THEN 'Crédito'
      ELSE 'Não identificado'
    END AS Debito_Credito,
    B.BELNR as Lcto_ctb, 
    B.DMBTR as Montante,
    B.SGTXT as Texto
FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as B
INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as F 
    ON B.MANDT = F.MANDT 
    AND B.LIFNR = F.LIFNR
WHERE 
    B.LIFNR > '1000000000' 
    AND B.SHKZG = 'S'
    AND B.AUGBL = ''  
    AND B.HKONT = '1010301001'
    AND DATE_DIFF(CURRENT_DATE(), B.H_BUDAT, DAY) > 30
