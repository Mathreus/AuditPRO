SELECT 
  CAJO_NUMBER AS Centro,
  POSTING_DATE AS Data_Lcto,
  POSTING_NUMBER AS Documento,
  CASE
    WHEN DOCUMENT_STATUS = 'P' THEN 'Lançado Êxito'
    WHEN DOCUMENT_STATUS = 'S' THEN 'Gravado com Êxito'
    WHEN DOCUMENT_STATUS = 'E' THEN 'Foram executadas verificações diálogo p/ entrada de dados'
    WHEN DOCUMENT_STATUS = 'D' THEN 'Documento Eliminado'
    WHEN DOCUMENT_STATUS = 'C' THEN 'Documento foi copiado'
    WHEN DOCUMENT_STATUS = 'R' THEN 'Documento Estornado'
    ELSE 'Classificar'
  END AS Status,
  ACCOUNTANT AS Usuario,
  H_RECEIPTS AS Montante_Recebido,
  H_PAYMENTS AS Montante_Pago,

  BP_NAME AS Descricao,
  D_POSTING_NUMB AS Num_Doc 
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.tcj_documents` AS DOC
WHERE
  DOCUMENT_STATUS = 'D'
