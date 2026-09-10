select distinct
  nf.bukrs as Empresa,
	concat(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
	nf.parid as ID_Externo,
	nf.name1 as Cliente,
  nf.cnpj_bupla as CNPJ,
	ped.vbeln as Pedido,
	nf.nfenum as Num_Nfe, 
  cli.erdat as Data_Cadastro,
  ped.erdat as Data_Pedido,
	min(nf.pstdat) as Dt_venda, 
  b.zlsch as FormaPgto,
	nf.nftot as Montante,
	relv.partner as cod_orig_vend, 
	concat(vend.bu_sort2,' ',vend.bu_sort1) as Vendedor
from
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
inner join  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item on
  ped.mandt = item.mandt and
  ped.vbeln = item.vbeln
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin on
  lin.xped = item.vbeln and
  lin.matnr = item.matnr and
  lin.itmnum = item.posnr 
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf on
  lin.mandt = nf.mandt and
  lin.docnum = nf.docnum
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as cli on
  ped.mandt = cli.mandt and
  ped.kunnr = cli.kunnr
inner join 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
	ped.mandt = relv.client and
	relv.idnumber = item.perve_ana
inner join
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend on
	ped.mandt = vend.client and
	relv.partner = vend.partner
inner join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as b on
	nf.mandt = nf.mandt and
  nf.pstdat = b.h_budat and
	nf.belnr = b.belnr  
where
  nf.mandt = '300' and
  cli.erdat between '2024-02-01' and '2024-02-29' and
  nf.pstdat between '2024-02-01'and '2024-02-29' and
  nf.direct = '2' and
  ped.abstk = 'A' and
  b.zlsch = 'E'
group by 
  nf.bukrs,
  nf.branch,
  nf.parid,
  nf.name1,
  nf.cnpj_bupla,
  ped.vbeln,
  nf.nfenum,
  cli.erdat,
  ped.erdat,
  b.zlsch,
  nf.nftot,
  relv.partner,
  vend.bu_sort2,
  vend.bu_sort1