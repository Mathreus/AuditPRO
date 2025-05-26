SELECT DISTINCT
  nf.bukrs AS Empresa,
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  NF.PARID AS Id_Externo,
  NF.NAME1 AS Cliente,
  PED.ERDAT AS DataPedido,
  REM.ERDAT AS DataRemessa,
  NF.PSTDAT AS DataNF,
  DATE_DIFF(CAST(NF.PSTDAT AS DATE), CAST(PED.ERDAT AS DATE), DAY) AS DiasPedidos_X_DiasNF,
  PED.VBELN AS Pedido,
  REM.VBELN AS Remessa,
  NF.NFENUM AS Num_nfe, 
  PED.NETWR AS ValorPedido,
  NF.NFTOT AS Faturamento,
   NF.NATOP AS Referencia,
  PED.VKBUR AS Equipe_Vendas,
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM 
  ON ped.mandt = rem.mandt 
  AND item.vbeln = rem.vgbel 
  AND item.posnr = rem.vgpos
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
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE
  nf.pstdat BETWEEN '2025-01-01' AND '2025-05-31' 
  AND nf.parid > '1000000000' 
  AND nf.nfenum IS NOT NULL   
  AND nf.direct = '2' 
  AND ped.abstk = 'A' 
  AND NF.NFTYPE = 'YC' 
  AND DATE_DIFF(CAST(NF.PSTDAT AS DATE), CAST(PED.ERDAT AS DATE), DAY) >= 3