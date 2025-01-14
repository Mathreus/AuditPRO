SELECT
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  NF.PARID AS Id_Externo,
  NF.NAME1 AS Cliente,
  PED.VBELN AS Pedido,
  COUNT(PED.VBELN) OVER (PARTITION BY PED.VBELN) AS Contagem,
  NF.NFENUM AS Num_nfe, 
  NF.PSTDAT AS Dt_lan, 
  NF.NFTOT AS Faturamento,
  NF.NATOP AS Nat_Op,
  PED.VKBUR AS Equipe_Vendas,
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) AS Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as ITEM ON
  ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
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
  nf.pstdat BETWEEN '2024-12-01' AND '2024-12-31'
--  AND PED.VBELN = '0007913177'
  AND nf.nfenum <> 'NULL'  
  AND nf.cancel <> 'X'
--  AND ped.vbeln = '0006294864' AND
  AND nf.direct = '2'
GROUP BY
  nf.bukrs,
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)),
  NF.LAND1,
  NF.REGIO,
  NF.INCO2,
  NF.PARID,
  NF.NAME1,
  PED.VBELN, 
  NF.NFENUM,
  NF.PSTDAT, 
  NF.NFTOT,
  NF.NATOP,
  PED.VKBUR,
  RELV.PARTNER, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1)