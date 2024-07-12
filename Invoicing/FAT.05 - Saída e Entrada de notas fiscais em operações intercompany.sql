-- NOTA FISCAL DE SAÍDA DA IMPORTADORA:

SELECT DISTINCT
	NF.BUKRS as EMPRESA_IMP,
	NF.BRANCH as LOCAL_NEGOCIOS_IMP,
	LEFT(NF.BUKRS, 2) + RIGHT(NF.BRANCH, 2) as CENTRO_IMP,
	NF.PSTDAT as DATA_LÇTO_IMP,
	NF.DIRECT as DIREÇAO_IMP,
	NF.PARTYP as TIPO_PARCEIRO_IMP,
	NF.PARID as ID_EXTERNO_IMP,
	NF.NAME1 as CLIENTE_IMP,
	NF.CANCEL as ESTORNADO_IMP,
	NF.NFENUM as NUM_NF_IMP,
	NF.NFTOT as MONTANTE_IMP
FROM
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as NF 
LEFT JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS DOC ON 
	NF.MANDT = DOC.MANDT AND 
	NF.PSTDAT = DOC.PSTDAT AND
	NF.DIRECT = DOC.DIRECT AND 
	NF.PARTYP = DOC.PARTYP AND 
	NF.PARID = DOC.PARID AND 
	NF.NAME1 = DOC.NAME1 AND
	NF.CANCEL = DOC.CANCEL AND 
	NF.NFENUM = DOC.NFENUM AND
	NF.NFTOT = DOC.NFTOT 
WHERE
	NF.MANDT = '300' AND
	NF.BUKRS = '1000' AND
	NF.PSTDAT BETWEEN '20230901' AND '20230930' AND
	NF.DIRECT = '2' AND
	NF.PARTYP = 'C' AND
	NF.PARID BETWEEN '0000002001' AND '0000002029' AND
	NF.CANCEL = '' 

-- NOTA FISCAL DE ENTRADA DA DISTRIBUIDORA:

SELECT
DISTINCT
	DOC.BUKRS as EMPRESA,
	DOC.BRANCH as LOCAL_NEGOCIOS,
	LEFT(DOC.BUKRS, 2) + RIGHT(DOC.BRANCH, 2) as CENTRO,
	DOC.PSTDAT as DATA_LÇTO,
	DOC.DIRECT as DIRECAO,
	DOC.PARTYP as TIPO_PARCEIRO,
	DOC.PARID as ID_EXTERNO,
	DOC.NAME1 as FORNECEDOR,
	DOC.CANCEL as ESTORNADO,
	DOC.NFENUM as NUM_NF,
	DOC.NFTOT as MONTANTE
FROM
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as DOC 
LEFT JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as NF ON 
		DOC.MANDT = NF.MANDT AND 
		DOC.PSTDAT = NF.PSTDAT AND
		DOC.DIRECT = NF.DIRECT AND 
		DOC.PARTYP = NF.PARTYP AND 
		DOC.PARID = NF.PARID AND 
		DOC.NAME1 = NF.NAME1 AND
		DOC.CANCEL = NF.CANCEL AND 
		DOC.NFENUM = NF.NFENUM AND
		DOC.NFTOT = NF.NFTOT 
WHERE
	DOC.MANDT = '300' AND
	DOC.BUKRS NOT IN ('1000') AND
	DOC.PSTDAT BETWEEN '2023-09-01' AND '2023-10-11' AND
	DOC.DIRECT = '1' AND
	DOC.PARTYP = 'V' AND
	DOC.PARID BETWEEN '0000001001' AND '0000001099' AND
	DOC.CANCEL = ''
ORDER BY
	LEFT(DOC.BUKRS, 2) + RIGHT(DOC.BRANCH, 2)