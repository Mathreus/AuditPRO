SELECT
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  cli.regio AS Regiao,
  cli.kunnr AS ID_Externo,
  cli.name1 AS Cliente,
  cli.erdat AS Data_Cadastro,
  NULL AS DataNF,  
  CURRENT_DATE() AS DataHoje,
  NULL AS Dias_Diferenca, 
  NULL AS NumeroNF,  
  NULL AS Montante,  
  MAX(lmt.credit_limit) AS Limite_Credito
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS cli
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
  cli.mandt = nf.mandt AND
  cli.kunnr = nf.parid
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
  nf.mandt = lin.mandt AND
  lin.docnum = nf.docnum
LEFT JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.ukmbp_cms_sgm` AS lmt ON
  lmt.partner = cli.kunnr AND
  lmt.client = '300'
WHERE
  cli.kunnr > '1000000000' AND
  cli.erdat > '2022-12-31' AND
  nf.pstdat IS NULL  
GROUP BY
  nf.bukrs,
  nf.branch,
  cli.regio,
  cli.erdat,
  cli.kunnr,
  cli.name1