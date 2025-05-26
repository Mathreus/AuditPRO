SELECT DISTINCT
	LIN.BWKEY as Centro,
	NF.PSTDAT as Data_lcto,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda'
    WHEN ped.spart = '04' THEN 'Marketplace'
    ELSE 'Não Identificado'
  END Canal,
  NF.PARID as ID_Externo,
	NF.NAME1 as Cliente,
	PED.VBELN as Pedido,
	NF.NFENUM as Num_nfe,  
	NF.NFTOT as Faturamento,
	RELV.PARTNER as Cod_orig_vend, 
	CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) as Vendedor
from
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as PED
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
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client and
  relv.partner = vend.partner
WHERE
  nf.pstdat BETWEEN '2025-01-01' and '2025-05-31' 
  AND nf.parid > '1000000000' 
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
	AND nf.direct = '2' 
  AND NF.NFTYPE = 'YC'
  AND nf.nftot < 10