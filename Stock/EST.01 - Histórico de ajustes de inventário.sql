select  
	est.bukrs as Empresa, 
	est.werks as Centro, 
	est.budat_mkpf as Data,
	est.lgort as Deposito,
	est.mblnr as Doc_Material,
	est.shkzg as D_C,
	est.bwart as Tipo_Movimento,
	right(est.matnr, 6) as Cod_Material,
  mat.maktx as Texto_Breve_Material,
	cast(est.menge as int) as QTD,
	est.salk3 as Montante, 
	est.usnam_mkpf as Usuario
from 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg` as est
inner join
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` as mat on
	est.mandt = mat.mandt and
	right(est.matnr, 6) = right(mat.matnr, 6)
where
	est.budat_mkpf between '2024-01-01' and '2024-06-30' and 
	est.bwart between '701' and '718'