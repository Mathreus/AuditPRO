SELECT DISTINCT 
    AF.BUKRS AS EMPRESA,
    F.LAND1 AS PAIS,
    AF.LIFNR AS COD_FORNECEDOR,
    F.NAME1 AS NOME_FORNECEDOR,
    AF.ZFBDT AS DATA_LCTO,
    AF.AUGDT AS DATA_COMPENSACAO,
    FORMAT_DATE('%d/%m/%Y', DATE_ADD(AF.ZFBDT, INTERVAL CAST(AF.ZBD1T AS INT64) DAY)) AS DT_VENCIMENTO,
    FORMAT_DATE('%d/%m/%Y', CURRENT_DATE()) AS DT_HOJE,
    AF.SHKZG AS D_C, 
    AF.BLART AS TIPO_LCTO, 
    AF.BELNR AS LCTO_CONTABIL,
    AF.SAKNR AS CTA_RAZAO,
    C.TXT20 AS Descricao_Conta_Razao,
    AF.DMBTR AS MONTANTE 
FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsik` AS AF
INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` AS F 
    ON AF.MANDT = F.MANDT 
    AND AF.LIFNR = F.LIFNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS C ON
    AF.HKONT = C.SAKNR
WHERE 
    AF.MANDT = '300' 
    AND F.LAND1 = 'BR' 
    AND AF.LIFNR > '1000000000'
--	AND AF.LIFNR = '1000005633' 
	AND AF.hkont = '1010301001'
    AND DATE_DIFF(CURRENT_DATE(), DATE_ADD(AF.ZFBDT, INTERVAL CAST(AF.ZBD1T AS INT64) DAY), DAY) > 30
