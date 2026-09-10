# Consultar no banco de dados os pedidos que predem o estoque - Comercial.
SELECT 
  PD.VBELN as DOC_VENDAS, 
  PD.ERDAT as DT_CRIACAO, 
  PD.ERNAM as CRIADO_POR, 
  PD.AUDAT as DT_DOCUMENTO, 
  PD.AUART as TP_DOC_VENDA, 
  PD.LIFSK as BLOQUEIO_REMESSA, 
  PD.NETWR as VLR_LIQ, 
  PD.VKORG as ORG_VENDAS, 
  PD.VTWEG as CANAL_DIST, 
  PD.VKGRP as EQP_VENDAS, 
  PD.VKBUR as ESC_VENDA, 
  PD.BSTNK as REF_CLIENTE, 
  PD.ABSTK as STATUS_RECUSA, 
  PD.VGBEL as DOC_REF, 
  PD.BUKRS_VF as EMP_FAT
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as PD 
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` as PD2 ON 
  PD.VBELN = PD2.VBELV 
WHERE 
  (PD2.VBELV IS NULL) AND  
  PD.ABSTK = 'A' AND 
  PD.LIFSK = '' AND 
  PD.AUART IN( 'OR1','ZCAS','ZPDV') AND
  PD.ERDAT > '2023-01-01' -- DATA ACUMULATIVA, NÃO PRECISA ALTERAR
ORDER BY 
  PD.ERDAT

# Consultar no banco de dados os pedidos que predem o estoque - Financeiro.

SELECT 
  PD.VBELN as DOC_VENDA,  
  PD.ERDAT as DT_CRIACAO, 
  PD.AUDAT as DT_DOC, 
  PD.AUART as TP_DOC_VENDA, 
  PD.LIFSK as BLOQUEIO_REMESSA, 
  PD.NETWR as VLR_LIQ, 
  PD.VKORG as ORG_VENDA, 
  PD.VKGRP as EQP_VENDA, 
  PD.VKBUR as ESC_VENDA, 
  PD.BSTNK as REF_CLIENTE, 
  PD.KNUMV as N_COND_DOC, 
  PD.VDATU as DATA_SOLIC_REME,
  PD.ABSTK as STATUS_RECUSA, 
  PD.BUKRS_VF as EMPR_SER_FAT, 
  PD.FMBDAT as DT_PREP_MAT, 
  ITEM.ABGRU as MOT_RECUSA 
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as PD
FULL OUTER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as ITEM ON 
  PD.VBELN = ITEM.VBELN 
WHERE 
  PD.MANDT = '300' AND 
  PD.LIFSK = '10' AND 
  ITEM.ABGRU = '' AND 
  PD.AUART IN( 'OR1','ZCAS','ZPDV') AND
  PD.ERDAT > '2023-01-01' -- DATA ACUMULATIVA, NÃO PRECISA ALTERAR
