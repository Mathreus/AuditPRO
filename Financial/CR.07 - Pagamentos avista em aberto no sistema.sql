SELECT 
	CONCAT(LEFT(AB.BUKRS, 2), RIGHT(AB.BUPLA, 2)) as Centro,
	AB.KUNNR as ID_Externo, 
	CAD.NAME1 as Cliente,
	AB.BUDAT as DataLcto,
	AB.AUGDT as DataCompensado, 
	CURRENT_DATE() as DataGeracao,
	AB.ZBD1T as DiasVencer,
	AB.BUDAT + CAST(AB.ZBD1T as INT64) as DataVencimento,
	EXTRACT(MONTH FROM AB.BUDAT + CAST(AB.ZBD1T as INT64)) as Num_Mes,
	FORMAT_DATE('%B', DATE(AB.BUDAT + CAST(AB.ZBD1T as INT64))) as Mes,
--	AB.ZLSCH as FormaPgto,
	CASE
		WHEN AB.ZLSCH = 'K' THEN 'PIX'
		ELSE 'Prazo'
	END FormaPgto,
	AB.ZTERM as CondPgto, 
	AB.XBLNR as NF, 
	AB.DMBTR as Montante, 
	AB.SGTXT as Ref_Cliente
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.bsid` as AB
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as CAD ON 
	AB.MANDT = CAD.MANDT AND 
	AB.KUNNR = CAD.KUNNR
WHERE 
	AB.ZLSCH IN ('K', 'O') AND 
	AB.BUDAT + CAST(AB.ZBD1T as INT64) BETWEEN '2024-01-01' AND '2024-06-30'
ORDER BY 
	EXTRACT(MONTH FROM AB.BUDAT + CAST(AB.ZBD1T as INT64)) ASC