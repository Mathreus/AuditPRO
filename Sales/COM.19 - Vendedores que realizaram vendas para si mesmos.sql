SELECT DISTINCT
  concat(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
  NF.PSTDAT as Dt_lan,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    ELSE 'Revenda'
  END SetorAtividade,
  NF.PARID as Id_Externo,
  NF.NAME1 as Cliente,
  PED.VBELN as Pedido,
  NF.NFENUM as Num_nfe,  
  NF.NFTOT as Faturamento,
  NF.NATOP AS Referencia,
  PED.VKBUR as Equipe_Vendas,
  RELV.PARTNER as Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` as fa ON
  ped.mandt = fa.mandt AND 
  ped.vbeln = fa.vbelv AND
  fa.vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` as fat ON
  fat.mandt = ped.mandt AND
  fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` as rp ON
  rp.mandt = ped.mandt AND
  fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin ON
  lin.mandt = ped.mandt AND
  rp.vbeln = lin.refkey AND
  rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf ON
  nf.mandt = ped.mandt AND
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
  NF.PSTDAT BETWEEN '2024-06-01' AND '2024-06-30'
  AND NF.NAME1 = CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AND
  NF.NATOP LIKE '%Vnd.mer%' AND
  NF.PARID > '1000000000' AND
  nf.nfenum <> 'NULL' and
  nf.cancel <> 'X' AND  
	nf.direct = '2' AND
  nf.natop LIKE '%Vnd.mer.%'