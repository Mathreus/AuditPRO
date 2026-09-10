SELECT DISTINCT		
	LIN.BWKEY AS 'CENTRO',
	LIN.REFKEY AS 'REFERENCIA', 
	LIN.CFOP,
	MSG.BUDAT_MKPF AS 'DATA',
	MSG.USNAM_MKPF AS 'USUARIO',
	J_1BNFDOC.NFNUM AS 'NUMERO NF', 
	MSG.BWART AS 'TP MOVIMENTO',
	MSG.KUNNR AS 'CLIENTE',
	MSG.MATBF AS 'COD PRODUTO', 
	LIN.MAKTX AS 'PRODUTOS', 
	MSG.MENGE AS 'QUANTIDADE',
	LIN.NETWR AS 'VALOR LÍQUIDO'
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin AS LIN
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc ON 
	LIN.DOCNUM = J_1BNFDOC.DOCNUM
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp ON 
	LIN.REFKEY = VBRP.VBELN
LEFT JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg AS MSG ON
	VBRP.VGBEL = MSG.XBLNR_MKPF
WHERE 
	MSG.BUDAT_MKPF BETWEEN '2024-01-01' AND '2024-06-30' AND
	MSG.BWART = '653' AND
	LIN.CFOP = '1202AA' AND 
	MSG.XBLNR_MKPF IS NULL