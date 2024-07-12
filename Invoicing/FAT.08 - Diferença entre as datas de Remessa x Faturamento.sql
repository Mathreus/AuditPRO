SELECT DISTINCT
  nf.bukrs AS Empresa,
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  NF.PARID AS Id_Externo,
  NF.NAME1 AS Cliente,
  PED.ERDAT AS DataPedido,
  REM.ERDAT AS DataRemessa,
  NF.PSTDAT AS DataNF,
  DATE_DIFF(CAST(REM.ERDAT AS DATE), CAST(PED.ERDAT AS DATE), DAY) AS DiasPedidos_X_DiasRemessa,
  PED.VBELN AS Pedido,
  REM.VBELN AS Remessa,
  NF.DIRECT AS DirecaoNF,
  NF.NFENUM AS Num_nfe, 
  PED.NETWR AS ValorPedido,
  NF.NFTOT AS Faturamento,
  NF.NATOP AS Referencia,
  PED.VKBUR AS Equipe_Vendas,
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS rem ON
  ped.mandt = rem.mandt AND
  item.vbeln = rem.vgbel AND
  item.posnr = rem.vgpos
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS fa ON
  ped.mandt = fa.mandt AND 
  ped.vbeln = fa.vbelv AND
  fa.vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS fat ON
  fat.mandt = ped.mandt AND
  fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS rp ON
  rp.mandt = ped.mandt AND
  fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
  lin.mandt = ped.mandt AND
  rp.vbeln = lin.refkey AND
  rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
  nf.mandt = ped.mandt AND
  lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv ON
  ped.mandt = relv.client AND
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend ON
  ped.mandt = vend.client AND
  relv.partner = vend.partner
WHERE
  nf.mandt = '300' AND
  nf.pstdat BETWEEN '2024-05-01' AND '2024-05-31' AND
  nf.parid > '1000000000' AND
  nf.cancel <> 'X' AND  
  nf.direct = '2' AND
  ped.abstk = 'A' AND
  nf.natop like '%Vnd.mer.adq%' AND
  DATE_DIFF(CAST(REM.ERDAT AS DATE), CAST(PED.ERDAT AS DATE), DAY) >= 2