SELECT 
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor,
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
  nf.pstdat between '2025-01-01' AND '2025-05-31' 
  AND nf.parid > '1000000000' 
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
  AND nf.direct = '2'
  AND ped.abstk = 'A'
  AND NF.NFTYPE = 'YC'
GROUP BY
  RELV.PARTNER,
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1)
ORDER BY
  RELV.PARTNER ASC
