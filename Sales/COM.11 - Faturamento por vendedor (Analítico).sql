
SELECT DISTINCT
	CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
	NF.PSTDAT as Dt_lan,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
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
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
inner join  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item on
  ped.mandt = item.mandt and
  ped.vbeln = item.vbeln
inner join 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` as fa on
  ped.mandt = fa.mandt and 
  ped.vbeln = fa.vbelv and
  vbtyp_n = 'M'
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` as fat on
  fat.mandt = ped.mandt and
  fa.vbeln = fat.vbeln
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` as rp on
  rp.mandt = ped.mandt and
  fat.vbeln = rp.vbeln
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin on
  lin.mandt = ped.mandt and
  rp.vbeln = lin.refkey and
  rp.matnr = lin.matnr
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf on
  nf.mandt = ped.mandt and
  lin.docnum = nf.docnum
inner join 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
  ped.mandt = relv.client and
  relv.idnumber = item.perve_ana
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend on
  ped.mandt = vend.client and
  relv.partner = vend.partner
WHERE
  nf.mandt = '300' AND
  nf.pstdat between '2022-05-01' and '2024-06-30' AND
  nf.parid > '1000000000' and
  nf.nfenum <> 'NULL' and
  nf.cancel <> 'X' AND  
  nf.direct = '2' AND
  nf.natop LIKE '%Vnd.mer.adq%'