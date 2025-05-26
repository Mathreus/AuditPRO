SELECT
  NF.REGIO AS Estado,
  NF.INCO2 AS Cidade,
  LIN.BWKEY AS Centro,
--  DATE(NF.PSTDAT) AS Data_lancamento,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda'
    WHEN ped.spart = '04' THEN 'Marketplace' 
    ELSE 'Não Identificado'
  END AS Canal,
  COUNT(DISTINCT PED.VBELN) AS Total_Pedidos,
  COUNT(DISTINCT NF.NFENUM) AS Total_NFs,
  SUM(NF.NFTOT) AS Faturamento_Total,
  ROUND(SUM(NF.NFTOT) / COUNT(DISTINCT NF.NFENUM), 2) AS Ticket_Medio,
  STRING_AGG(DISTINCT TRIM(CONCAT(COALESCE(VEND.BU_SORT2,''), ' ', COALESCE(VEND.BU_SORT1,''))), ', ') AS Vendedores
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS FA 
  ON ped.mandt = fa.mandt 
  AND ped.vbeln = fa.vbelv 
  AND fa.vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS FAT 
  ON fat.mandt = ped.mandt 
  AND fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS RP 
  ON rp.mandt = ped.mandt 
  AND fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN 
  ON lin.mandt = ped.mandt 
  AND rp.vbeln = lin.refkey 
  AND rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF 
  ON nf.mandt = ped.mandt 
  AND lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
  ON relv.client = vend.client 
  AND relv.partner = vend.partner
WHERE
  DATE(NF.PSTDAT) BETWEEN DATE('2025-04-01') AND DATE('2025-04-30')
  AND nf.parid > '1000000000'
  AND nf.nfenum IS NOT NULL
  AND nf.cancel <> 'X'   
  AND nf.direct = '2' 
  AND nf.nftype = 'YC'
GROUP BY
  Estado, Cidade, Centro, Canal
ORDER BY
  Estado, Cidade