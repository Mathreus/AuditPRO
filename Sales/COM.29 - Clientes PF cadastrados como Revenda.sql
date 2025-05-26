SELECT 
  CLI.REGIO AS Estado,
  CLI.ORT01 AS Cidade,
  CLI.ERDAT AS Data_Criacao,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    WHEN PED.SPART = '02' THEN 'Revenda'
    WHEN PED.SPART = '04' THEN 'Marketplace'
  END Canal,
  CLI.KUNNR AS ID_Externo,
  CLI.NAME1 AS Cliente,
  CLI.STCD2 AS CPF_ou_CNPJ,
  LENGTH(CLI.STCD2) AS QuantidadeCaracteres,
  SUM(LIN.NETWR) AS Faturamento_Total
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED 
  ON cli.mandt = ped.mandt  
  AND cli.kunnr = ped.kunnr
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN 
  ON lin.xped = item.vbeln 
  AND lin.matnr = item.matnr 
  AND lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF 
  ON lin.mandt = nf.mandt 
  AND lin.docnum = nf.docnum
WHERE
  PED.SPART = '02' 
  AND LENGTH(CLI.STCD1) <> 14 
  AND nf.parid > '1000000000' 
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X' 
  AND nf.direct = '2'
GROUP BY
  CLI.REGIO,
  CLI.ORT01,
  CLI.ERDAT,
  PED.SPART,
  CLI.KUNNR,
  CLI.NAME1,
  CLI.STCD2,
  LENGTH(CLI.STCD2)