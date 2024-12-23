SELECT
DISTINCT
  DOC.BUKRS as EMPRESA, 
  DOC.BRANCH as CENTRO, 
  DOC.DOCNUM as NUM_DOCUMENTO, 
  DOC.DOCDAT as DATA_DOCUMENTO, 
  DOC.PARID as CLIENTE, 
  DOC.NFENUM as NUM_NF,
  DOC.NATOP as NAT_OP,
  (FAT.NETWR + FAT.MWSBK) as VLR_FAT, 
  SUM(FIN.DMBTR) as VLR_FIN
FROM 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc as DOC
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk as FAT 
  ON DOC.NFENUM = LEFT(FAT.XBLNR,9) AND 
  FAT.KUNAG = DOC.PARID AND 
  FAT.BUPLA = DOC.BRANCH AND 
  FAT.VBTYP = 'M'
LEFT JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg as FIN  
  ON FIN.VBELN = FAT.VBELN AND 
  FIN.SHKZG = 'S' AND 
  FIN.H_BLART = 'RV'
WHERE 
  DOC.DIRECT = '2' AND
  DOC.DOCTYP = '1' AND 
  DOC.NFTYPE = 'YC' AND
  DOC.CANCEL <> 'X' AND
  DOC.DOCDAT BETWEEN '2024-12-01' AND '2024-12-01'
GROUP BY 
  DOC.BUKRS, 
  DOC.BRANCH, 
  DOC.DOCNUM, 
  DOC.DOCDAT, 
  DOC.PARID, 
  DOC.NFENUM, 
  FAT.NETWR, 
  FAT.MWSBK,
  DOC.NATOP
