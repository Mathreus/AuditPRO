SELECT 
  PED.SPART AS SetorAtividade,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 1 THEN LIN.NETWR ELSE 0 END) AS Janeiro,
  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 2 THEN LIN.NETWR ELSE 0 END) AS Fevereiro,
  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 3 THEN LIN.NETWR ELSE 0 END) AS Marco,
  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 4 THEN LIN.NETWR ELSE 0 END) AS Abril,
  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 5 THEN LIN.NETWR ELSE 0 END) AS Maio,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 6 THEN LIN.NETWR ELSE 0 END) AS Junho,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 7 THEN LIN.NETWR ELSE 0 END) AS Julho,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 8 THEN LIN.NETWR ELSE 0 END) AS Agosto,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 9 THEN LIN.NETWR ELSE 0 END) AS Setembro,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 10 THEN LIN.NETWR ELSE 0 END) AS Outubro,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 11 THEN LIN.NETWR ELSE 0 END) AS Novembro,
--  SUM(CASE WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 12 THEN LIN.NETWR ELSE 0 END) AS Dezembro,
  SUM(LIN.NETWR) AS Faturamento_Total
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
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv ON
  ped.mandt = relv.client AND
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client AND
  relv.partner = vend.partner
WHERE
  nf.mandt = '300' AND
  ped.abstk = 'A' AND
  nf.pstdat between '2024-01-01' and '2024-05-31' and
  nf.parid > '1000000000' and
  nf.nfenum <> 'NULL' and
  nf.cancel <> 'X' AND  
	nf.direct = '2' AND  
  nf.natop LIKE '%Vnd.mer.adq%'
GROUP BY
  PED.SPART,
  NF.PARID,
  NF.NAME1