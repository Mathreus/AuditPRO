SELECT DISTINCT
  FIN.BUKRS AS COD_EMPRESA,
  EMP.BUTXT AS EMPRESA,
  FIN.KUNNR as COD_CLIENTE,
  CLI.NAME1 AS CLIENTE,
  FIN.BELNR as DOC_CONTABIL,
  FIN.BUZEI AS ITEM_CONTABIL,
  FIN.DMBTR as VALOR_TIT,
  FIN.SGTXT AS DESCRICAO,
  FIN.H_BLART AS COD_TIPO_DOCUMENTO_CONTABIL,
  cdhdr.CHANGENR as DOC_ALTERACAO,
  cdhdr.USERNAME as USUARIO,
  cdpos.VALUE_OLD as VALOR_ANTIGO,
  cdpos.VALUE_NEW as VALOR_NOVO,
  cdhdr.UDATE as DT_ALTERACAO,
  cdhdr.TCODE as TRANSACAO,
  cdhdr.CHANGE_IND as TP_MODIF,
  CASE WHEN cdhdr.CHANGE_IND = 'U' THEN 'ATUALIZACAO' 
       WHEN cdhdr.CHANGE_IND = 'I' THEN 'INSERIDO' 
       WHEN cdhdr.CHANGE_IND = 'D' THEN 'DELETADO' END AS TP_ALTERACAO, 
  cdpos.FNAME as CAMPO_ALTERADO,
  'DATA BASE PARA PAGAMENTO' as DESCRICAO_CAMPO,
  FIN.BUPLA AS LOCAL_NEG,
  FIN.H_BUDAT as DT_LANCAMENTO,
  FIN.AUGDT as DT_COMPENSACAO,
  FIN.NETDT as DT_VENCIMENTO,
  FIN.ZLSCH as FORM_PAG,
  FIN.HBKID as BANCO
FROM		
	production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg AS FIN
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.cdpos ON CONCAT(FIN.BUKRS,FIN.BELNR, FIN.GJAHR, FIN.BUZEI) = RIGHT(cdpos.TABKEY,21)
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.cdhdr ON cdhdr.CHANGENR = cdpos.CHANGENR 
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001` AS EMP ON 
  EMP.BUKRS = FIN.BUKRS
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI ON
  CLI.KUNNR = FIN.KUNNR
WHERE
  FIN.SHKZG = 'S'
  AND cdpos.FNAME = 'ZFBDT'
  AND cdpos.TABNAME = 'BSEG'
  AND cdhdr.udate BETWEEN '2024-07-01' AND '2024-07-31'