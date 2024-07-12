SELECT 
DISTINCT 
  DOC.DOCNUM as DOC_NFE, 
  DOC.BUKRS as IMPORTADORA_NFE, 
  DOC.BRANCH as UNIDADE_IMP_NFE, 
  DOC.DOCDAT as DT_NFE, 
  DOC.PARID as COD_DIST_NFE,
  DOC.NFENUM as NFE_NUM, 
  CTE.DOCNUM as DOC_CTE_SITEMA, 
  CTE.NFENUM as NOTA_CTE,
  CTE.NFTOT as VLR_FRETE ,
  CTE.BUKRS as EMPRESA_CTE, 
  CTE.BRANCH as UNIDADE_CTE, 
  CTE.DOCDAT as DT_CTE, 
  CTE.PARID as COD_TRANSP_CTE, 
  FORN.NAME1 as NOME_TRANSP, 
  LIN.COD_CTA as CONTA_CONTABIL, 
  LIN.REFKEY as REF_FINANCEIRO
FROM 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc AS DOC
  INNER JOIN production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bcte_d_docref AS
  REF ON DOC.NFENUM =  REF.NFNUM9 AND 
  DOC.CNPJ_BUPLA = REF.STCD1 AND 
  DOC.NFTOT = REF.DOCVAL
  INNER JOIN production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc AS CTE 
  ON REF.DOCNUM = CTE.DOCNUM
  INNER JOIN production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1 AS FORN 
  ON FORN.LIFNR = CTE.PARID
  INNER JOIN production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin AS LIN 
  ON CTE.DOCNUM = LIN.DOCNUM
WHERE 
  CTE.CANCEL <> 'X' 
  AND DOC.MODEL = '55' 
  AND CTE.MODEL = '57' 
  AND DOC.BUKRS = '1000'
  AND DOC.PARID  < '10000' 
  AND LIN.COD_CTA <> '1010501001' 
  AND CTE.BUKRS > '1000' 
  AND CTE.DOCDAT BETWEEN '2024-06-01' AND '2024-06-30'