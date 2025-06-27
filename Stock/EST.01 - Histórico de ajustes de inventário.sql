SELECT 
	est.werks AS Centro, 
	est.budat_mkpf AS Data_Est,
	est.lgort AS Deposito,
	est.mblnr AS Doc_Material,
	CASE
		WHEN est.shkzg = 'S' THEN 'Entrada'
		WHEN est.shkzg = 'H' THEN 'Saída'
		ELSE 'Não Identificado'
	END Movimento,
	est.bwart AS Ajuste,
	est.CPUTM_MKPF AS horario,
	right(est.matnr, 6) AS Cod_Material,
  mat.maktx AS Texto_Breve_Material,
	cast(est.menge AS int) AS QTD,
	EST.DMBTR AS Valor,
	est.usnam_mkpf AS Usuario
FROM
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg` AS EST
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS MAT 
	ON est.mandt = mat.mandt
	AND RIGHT(EST.MATNR, 6) = RIGHT(MAT.MATNR, 6)
WHERE
	EST.BUDAT_MKPF BETWEEN '2025-06-01' AND '2025-06-30' 
	AND EST.BWART IN ('309','701', '702', '711', '712')
ORDER BY
	EST.WERKS
