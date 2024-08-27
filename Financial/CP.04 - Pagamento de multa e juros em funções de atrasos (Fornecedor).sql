SELECT DISTINCT 
  B.BUKRS as Empresa,
  B.AUGCP as Data_Compensacao, 
  B.H_BLART as Tipo_Lancamento,
  CASE
    WHEN B.SHKZG = 'S' THEN 'Débito'
    ELSE 'Crédito'
  END Deb_Cred,
  B.AUGBL as Documento_Compensacao,
  B.NEBTR as Pgto_Total,
  B.DMBTR as Montante,
  B.NEBTR - B.DMBTR AS Juros
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as B
WHERE 
  B.AUGCP = B.AUGDT 
  AND B.BSCHL = '25'
  AND B.SHKZG = 'S' 
  AND B.H_BLART = 'KZ' 
  AND B.NEBTR > B.DMBTR
  AND B.NEBTR - B.DMBTR > 1
