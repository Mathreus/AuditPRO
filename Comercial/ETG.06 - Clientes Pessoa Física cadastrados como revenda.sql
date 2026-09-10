SELECT 
  CLI.REGIO AS Estado,
  CLI.ORT01 AS Cidade,
  CLI.ERDAT AS DataCriacao,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    ELSE 'Revenda'
  END AS SetorAtividade,
  CLI.KUNNR AS ID_Externo,
  CLI.NAME1 AS Cliente,
  CLI.STCD2 AS CPF_ou_CNPJ,
  LENGTH(CLI.STCD2) AS QuantidadeCaracteres,
  SUM(LIN.NETWR) AS Faturamento_Total
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS cli
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped ON
  cli.mandt = ped.mandt AND 
  cli.kunnr = ped.kunnr
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
  lin.xped = item.vbeln AND
  lin.matnr = item.matnr AND
  lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
  lin.mandt = nf.mandt AND
  lin.docnum = nf.docnum
WHERE
  PED.SPART = '02' AND
  LENGTH(CLI.STCD1) <> 14 AND
  nf.parid > '1000000000' AND
  nf.nfenum <> 'NULL' AND
  nf.cancel <> 'X' AND  
  nf.direct = '2'
GROUP BY
  CLI.REGIO,
  CLI.ORT01,
  CLI.ERDAT,
  PED.SPART,
  CLI.KUNNR,
  CLI.NAME1,
  CLI.STCD2,
  LENGTH(CLI.STCD2)