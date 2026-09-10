SELECT DISTINCT
  CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
	NF.PSTDAT AS Data_lcto, 
	NF.CRENAM AS Usuario,
	NF.PARID AS ID_Externo,
	CLI.NAME1 AS Cliente,
	NF.NFENUM AS NumNF,
	NF.NFTOT AS Montante,
FROM 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI ON 
	NF.MANDT = CLI.MANDT AND
	NF.PARID = CLI.KUNNR
WHERE 
	NF.DOCTYP = '1' AND
	NF.DIRECT = '2' AND
	NF.DOCDAT BETWEEN '2024-07-01' AND '2024-07-31' AND
	NF.MANUAL = 'X' AND
	NF.CRENAM <> 'INTEGRACAO' AND
	NF.CANCEL <> 'X'
ORDER BY
	NF.PSTDAT