SELECT DISTINCT 
	CH.OBJECTID 'ID',
	K.NAME1 'NOME',
	CH.USERNAME 'USUARIO',
	CH.UDATE 'DATA',
	CD.VALUE_OLD 'VLR_ANTIGO',
	CD.VALUE_NEW 'VLR_NOVO' 
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.CDPOS AS CD 
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.cdhdr` AS CH ON
	CD.MANDANT = CH.MANDANT AND
	CD.OBJECTID = CH.OBJECTID AND
	CD.OBJECTCLAS = CH.OBJECTCLAS AND
	CD.CHANGENR = CH.CHANGENR 
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS K ON
	CD.MANDANT = K.MANDT AND
	CH.OBJECTID = K.KUNNR 
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.knvv` ON
	KNVV.KUNNR = K.KUNNR 
WHERE
	CD.MANDANT = '300' AND
	CD.FNAME = 'CREDIT_LIMIT' AND
	CH.UDATE BETWEEN '2024-00-01' AND '2024-06-30' AND
	CH.OBJECTID = '1000001738'
GROUP BY 
	CH.OBJECTID, 
	K.NAME1,
	CH.USERNAME,
	CH.UDATE,
	CD.VALUE_OLD,
	CD.VALUE_NEW