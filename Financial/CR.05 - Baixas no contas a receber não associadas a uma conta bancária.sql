SELECT DISTINCT
	B.MANDT,
	B.BUKRS AS 'EMPRESA',
	B.BELNR AS 'DOC_LAN', 
	A.AUGBL AS 'COMP',
	A.AUGCP AS 'DT_COMP',
	B.HKONT AS 'CONTA_CONTABIL',
	B.BSCHL 'OPE', 
	B.FDLEV 'NIVEL', 
	B.HBKID 'BANCO',
	B.H_BLART 'TP'
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS A
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B ON 
	A.BELNR = B.BELNR AND
	A.BUKRS = B.BUKRS AND
	B.BSCHL = 40 AND
	B.SHKZG = 'S'
WHERE 
	B.MANDT = '300' AND
	A.HKONT = '1010201001' AND
	A.BSCHL = 15  AND
	A.H_BLART = 'DZ' AND
	B.HBKID = '' AND
	A.AUGCP BETWEEN '2024-01-01' AND '2023-06-30' AND
	A.KOART = 'D' AND
	B.HKONT NOT IN ('3040302013', '3040302009', '3040101012', '3010101001', '1010102901', '1010102902') AND 
	A.AUGBL NOT LIKE '9020%'