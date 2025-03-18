SELECT DISTINCT
  FIN.BUKRS AS COD_EMPRESA,
  FIN.BUPLA AS LOCAL_NEG,
  EMP.BUTXT AS EMPRESA,
  FIN.KUNNR AS COD_CLIENTE,
  CLI.NAME1 AS CLIENTE,
  FIN.BELNR AS DOC_CONTABIL,
  FIN.BUZEI AS ITEM_CONTABIL,
  FIN.DMBTR AS VALOR_TIT,
  FIN.SGTXT AS DESCRICAO,
  FIN.H_BLART AS COD_TIPO_DOCUMENTO_CONTABIL,
  cdhdr.CHANGENR AS DOC_ALTERACAO,
  cdhdr.USERNAME AS USUARIO,
  FORMAT_DATE('%d/%m/%Y', PARSE_DATE('%Y%m%d', cdpos.VALUE_OLD)) AS VENCIMENTO_ANTIGO,
  FORMAT_DATE('%d/%m/%Y', PARSE_DATE('%Y%m%d', cdpos.VALUE_NEW)) AS VENCIMENTO_NOVO,
  DATE_DIFF(PARSE_DATE('%Y%m%d', cdpos.VALUE_NEW), PARSE_DATE('%Y%m%d', cdpos.VALUE_OLD), DAY) AS DIF_DIAS,
  cdhdr.UDATE AS DT_ALTERACAO,
  cdhdr.TCODE AS TRANSACAO,
  cdhdr.CHANGE_IND AS TP_MODIF,
  CASE 
    WHEN cdhdr.CHANGE_IND = 'U' THEN 'ATUALIZACAO' 
    WHEN cdhdr.CHANGE_IND = 'I' THEN 'INSERIDO' 
    WHEN cdhdr.CHANGE_IND = 'D' THEN 'DELETADO' 
  END AS TP_ALTERACAO, 
  cdpos.FNAME AS CAMPO_ALTERADO,
  'DATA BASE PARA PAGAMENTO' AS DESCRICAO_CAMPO,
  FIN.H_BUDAT AS DT_LANCAMENTO,
  FIN.AUGDT AS DT_COMPENSACAO,
  FIN.NETDT AS DT_VENCIMENTO,
  FIN.ZLSCH AS FORM_PAG,
  VEN.CNAME AS VENDEDOR
FROM		
  production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg AS FIN
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.cdpos 
  ON CONCAT(FIN.BUKRS, FIN.BELNR, FIN.GJAHR, FIN.BUZEI) = RIGHT(cdpos.TABKEY, 21)
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.cdhdr 
  ON cdhdr.CHANGENR = cdpos.CHANGENR 
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001` AS EMP 
  ON EMP.BUKRS = FIN.BUKRS
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI 
  ON CLI.KUNNR = FIN.KUNNR
INNER JOIN  
  `Portal_do_Vendedor.Clientes_x_Vendedores` AS VEN
  ON CLI.KUNNR = VEN.KUNNR
WHERE
  FIN.SHKZG = 'S'
  AND cdpos.FNAME = 'ZFBDT'
  AND cdpos.TABNAME = 'BSEG'
  AND cdhdr.UDATE > '2022-01-01'
