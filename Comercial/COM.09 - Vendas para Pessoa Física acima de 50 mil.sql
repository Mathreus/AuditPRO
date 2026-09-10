SELECT 
  nf.parid as ID_Externo,
  nf.name1 as Cliente,
  SUM(nf.nftot) as Total_Faturamento
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin ON
  lin.xped = item.vbeln AND
  lin.matnr = item.matnr AND
  lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf ON
  lin.mandt = nf.mandt AND
  lin.docnum = nf.docnum
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as cli ON
  ped.mandt = cli.mandt AND
  ped.kunnr = cli.kunnr
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv ON
  ped.mandt = relv.client AND
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client AND
  relv.partner = vend.partner
WHERE 
  ped.abstk = 'A' AND
  ped.auart IN ('OR1', 'ZPDV', 'ZCAS') AND
  nf.partyp = 'C' AND
  nf.pstdat BETWEEN '2024-05-01' AND '2024-05-31' AND
  nf.parid > '1000000000' AND
  nf.cpf <> '' AND
  nf.cpf <> '00000000000' AND
  nf.direct = '2' AND
  nf.nftype = 'YC' AND
  nf.cancel <> 'X'
GROUP BY 
  nf.parid, 
  nf.name1
HAVING 
  SUM(nf.nftot) > 50000
ORDER BY 
  Total_Faturamento DESC;