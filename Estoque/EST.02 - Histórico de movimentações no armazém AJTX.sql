select 
	est.bukrs as Empresa, 
	est.werks as Centro, 
	est.budat_mkpf as Data, 
	est.lgort as Deposito,
	est.mblnr as Doc_Material,
	right(est.matnr, 6) as Material,
	est.bwart as Tipo_Movimento,
	est.shkzg as D_C, 
	est.menge as QTD,
	est.salk3 as Montante,
	est.usnam_mkpf as Usuario
from 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg` as est
where 
	est.mandt = '300' and 
	est.budat_mkpf between '2024-01-01' AND '2024-01-31' AND 
	est.lgort = 'AJTX'
order by
	est.werks