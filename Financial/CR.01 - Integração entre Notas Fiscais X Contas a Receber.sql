SELECT DISTINCT
	DOC.BUKRS AS 'EMPRESA',
	DOC.BRANCH AS 'CENTRO',
	DOC.DOCNUM AS 'NUM_DOCUMENTO', 
	DOC.DOCDAT AS 'DATA_DOCUMENTO', 
	DOC.PARID AS 'CLIENTE', 
	DOC.FORM AS 'FORMA_DOCUMENTO',
	DOC.NFENUM AS 'NUM_NF',
	DOC.ZTERM AS 'CONDICAO_PGTO', 
	DOC.NFTOT AS 'VLR_NF', 
	SAD.DMBTR, SID.DMBTR, 
	SUM(SAD.DMBTR + SID.DMBTR) AS 'VLR_TOTAL',
	SUM(SAD.DMBTR + SID.DMBTR) - DOC.NFTOT AS 'DIF_VLR'
FROM 
	 `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc AS DOC
INNER JOIN 
	 `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsad` AS SAD ON 
	DOC.ZTERM = SAD.ZTERM 
LEFT JOIN 
	 `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsid` AS SID ON 
	SAD.XBLNR = SID.XBLNR
WHERE
	DOC.FORM = 'NF55'