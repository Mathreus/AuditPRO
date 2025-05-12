SELECT DISTINCT
	CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
	NF.PSTDAT as Dt_lan,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda' 
    ELSE 'Nada'
  END Canal,
  NF.PARID as ID_Externo,
	NF.NAME1 as Cliente,
	PED.VBELN as Pedido,
	NF.NFENUM as Num_nfe,  
	NF.NFTOT as Faturamento,
--  NF.NATOP AS Referencia,
  PED.VKGRP AS Equipe_Vendas,
  PED.VKBUR as Escritorio_Vendas,
	RELV.PARTNER as Cod_orig_vend, 
	CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item on
  ped.mandt = item.mandt and
  ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` as fa on
  ped.mandt = fa.mandt and 
  ped.vbeln = fa.vbelv and
  vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` as fat on
  fat.mandt = ped.mandt and
  fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` as rp on
  rp.mandt = ped.mandt and
  fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin on
  lin.mandt = ped.mandt and
  rp.vbeln = lin.refkey and
  rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf on
  nf.mandt = ped.mandt and
  lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
  ped.mandt = relv.client and
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client and
  relv.partner = vend.partner
WHERE
--  CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) = '2015' AND
  nf.pstdat BETWEEN '2025-04-01' and '2025-04-30' 
  AND nf.parid > '1000000000'
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
	AND nf.direct = '2' 
  AND nf.nftype = 'YC'
--  AND CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) LIKE '%%'
--  AND NF.NAME1 LIKE '%%'
