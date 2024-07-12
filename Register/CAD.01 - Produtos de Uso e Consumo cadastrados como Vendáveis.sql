SELECT
	cps.bukrs as Empresa,
	cps.werks as Centro,
	cps.aedat as Data,
	cps.lgort as Deposito,
	cps.matkl as GP_Mercadoria,
	right(cps.matnr, 6) as Cod_Material, 
	cps.txz01 as Descricao,
	cps.menge as QTD,
	cps.netpr as Preco_Unitario,
	cps.netwr as Valor_Total 
from 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.ekpo` as cps
where 
	cps.mandt = '300' and
	cps.aedat between '2023-12-01' and '2023-12-31' and
	cps.lgort = 'DREV' and
	right(cps.matnr, 6) > '199999' and
	cps.matkl in ('USOC')