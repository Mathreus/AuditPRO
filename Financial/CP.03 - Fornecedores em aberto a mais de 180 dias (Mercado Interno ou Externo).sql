SELECT DISTINCT
	SD.BUKRS as Empresa,
	SD.KUNNR as ID_Externo,
	CAD.NAME1 as Cliente,
	SD.BUDAT as Data_Lcto,
	SD.AUGDT as Data_Compensacao,
	SD.AUGBL as Doc_Compensacao,
	SD.BLART as Tipo_Documento,
	CASE
		WHEN SD.SHKZG = 'S' THEN 'Débito'
		WHEN SD.SHKZG = 'H' THEN 'Crédito'
		ELSE 'Não Identificado'
	END Debito_Credito,
	SD.SAKNR as Conta_Contabil, 
	FAT.USNAM as Usuario,
	SD.XBLNR as Referencia,
	SD.BUZEI as Parcela,
	SD.DMBTR as Montante
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.bsad` as SD
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` as FAT ON
	SD.BUKRS = FAT.BUKRS 
	AND SD.GJAHR = FAT.GJAHR 
	AND SD.BELNR = FAT.BELNR
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as CAD 
	ON SD.MANDT = CAD.MANDT 
	AND SD.KUNNR = CAD.KUNNR 
WHERE 
	SD.KUNNR > '1000000000'  
	AND SD.AUGDT BETWEEN '2024-12-01' AND '2025-01-03' 
--	AND SD.AUGDT = '2025-01-02'
	AND SD.BLART = 'ES' 
	AND FAT.USNAM <> 'JOB_USER'
ORDER BY
	CAD.NAME1
