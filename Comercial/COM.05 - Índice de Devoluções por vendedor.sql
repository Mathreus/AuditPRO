SELECT DISTINCT
	LIN.BWKEY as Centro,
  	nf.PSTDAT as Dt_Lan,
	nf.parid as ID_Externo,
	nf.name1 as Cliente,
	ped.vbeln as Pedido,
	nf.nfenum as Num_Nfe, 
	nf.nftot as Devolucao,
	ped.vkbur as EscrVen,
	relv.partner as cod_orig_vend, 
	concat(vend.bu_sort2,' ',vend.bu_sort1) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item on
  ped.mandt = item.mandt and
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin on
  lin.xped = item.vbeln and
  lin.matnr = item.matnr and
  lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf on
  lin.mandt = nf.mandt and
  lin.docnum = nf.docnum
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as cli on
  ped.mandt = cli.mandt and
  ped.kunnr = cli.kunnr
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
	ped.mandt = relv.client and
	relv.idnumber = item.perve_ana
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend on
	ped.mandt = vend.client and
	relv.partner = vend.partner
WHERE
	nf.pstdat between '2025-03-01' and '2024-05-31' and
  	nf.parid > '1000000000' and
	ped.vbeln like '%006%' and
	nf.cancel <> 'X' and 
	nf.nfenum <> 'NULL' and  
	nf.direct = '1' and 
	nf.natop like '%Dev.%'
