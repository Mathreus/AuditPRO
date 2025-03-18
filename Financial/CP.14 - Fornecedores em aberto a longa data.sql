SELECT DISTINCT 
  B.BUKRS as Empresa,
  B.BUPLA as Local_Negocios,
  B.LIFNR as ID_Fornecedor, 
  F.NAME1 as Forneedor, 
  B.BELNR as Documento,
  B.H_BLART AS Tipo_Documento,
  B.AUGCP as Data_Compensacao, 
  B.H_BUDAT as Data_Lancamento,
  EXTRACT(MONTH FROM B.H_BUDAT) AS Mes,
  EXTRACT(YEAR FROM B.H_BUDAT) AS Ano,
  FORMAT_DATE('%m-%y', B.H_BUDAT) AS Mes_Ano,
  CURRENT_DATE() AS Data_Hoje,
  B.H_BUDAT + CAST(B.ZBD1T AS INT64) AS Data_Vencimento,
  DATE_DIFF(CURRENT_DATE(),B.H_BUDAT, DAY) as Dif_Data,
  CASE  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) <= 30 THEN 'Até 30 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 31 AND 60 THEN 'Até 60 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 61 AND 90 THEN 'Até 90 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 91 AND 120 THEN 'Até 120 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 121 AND 150 THEN 'Até 150 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 151 AND 180 THEN 'Até 180 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) BETWEEN 181 AND 360 THEN 'Até 360 dias'  
    WHEN DATE_DIFF(CURRENT_DATE(), B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) > 360 THEN '+360 Dias'  
  END Aging_List,   
  CASE
    WHEN B.SHKZG = 'S' THEN 'Débito'
    WHEN B.SHKZG = 'H' THEN 'Crédito'
    ELSE 'Não identificado'
  END Debito_Credito, 
  B.DMBTR as MONTANTE,
  B.SGTXT as TEXTO
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as B
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as F 
  ON B.MANDT = F.MANDT 
  AND B.LIFNR = F.LIFNR
WHERE  
  B.LIFNR > '1000000000'
  AND F.LAND1 = 'BR'
--  B.LIFNR = '1000001309' 
  AND DATE_DIFF(CURRENT_DATE(),B.H_BUDAT + CAST(B.ZBD1T AS INT64), DAY) > 5 
  AND B.AUGBL = '' 
  AND B.H_BLART IN ('KZ', 'ZP', 'RE', 'KR')
