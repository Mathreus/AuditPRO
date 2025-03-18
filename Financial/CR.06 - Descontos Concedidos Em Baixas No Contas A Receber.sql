SELECT DISTINCT  
  FIN.BUKRS AS Empresa,
  FIN.H_BUDAT AS Data_Lcto,
  EXTRACT(YEAR FROM FIN.H_BUDAT) AS Ano,
  EXTRACT(MONTH FROM FIN.H_BUDAT) AS Mes,
  CONCAT(CAST(EXTRACT(YEAR FROM FIN.H_BUDAT) AS STRING), "/", CAST(EXTRACT(MONTH FROM FIN.H_BUDAT) AS STRING)) AS Mes_Ano,
  BK.USNAM AS Usuario,
  CASE
    WHEN FIN.KOART = 'A' THEN 'Anexos'
    WHEN FIN.KOART = 'D' THEN 'Clientes'
    WHEN FIN.KOART = 'K' THEN 'Fornecedores'
    WHEN FIN.KOART = 'M' THEN 'Material'
    WHEN FIN.KOART = 'S' THEN 'Contas do Razão'
    ELSE 'Não identificado'
  END AS Tipo_Conta,
  FIN.H_BLART AS Tipo_Lcto,
  CASE
    WHEN FIN.SHKZG = 'S' THEN 'Débito'
    WHEN FIN.SHKZG = 'H' THEN 'Crédito'
    ELSE 'Não identificado'
  END AS Debito_Credito,
  FIN.BELNR AS NumDocumento,
  FIN.HKONT AS Conta_Contabil,
  PLANO.TXT20 AS Conta_Razao_Resultado,
  FIN.DMBTR AS Montante,
  FIN.SGTXT AS Texto
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS FIN
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` AS BK 
  ON FIN.BUKRS = BK.BUKRS 
  AND FIN.BELNR = BK.BELNR 
  AND FIN.GJAHR = BK.GJAHR
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS PLANO 
  ON PLANO.KTOPL = '1000'
  AND PLANO.SAKNR = FIN.HKONT
WHERE 
  (FIN.HKONT = '3020101003' 
   OR FIN.HKONT = '3030402004' 
   OR FIN.HKONT = '3030402005' 
   OR FIN.HKONT = '3040302004') 
  AND FIN.H_BLART IN ('DZ', 'DG', 'C2', 'DA', 'DR', 'DS', 'DV', 'DX', 'DY', 'RX') 
  AND FIN.H_BLART <> 'ES'
  AND FIN.H_BSTAT <> 'J' 
  AND FIN.H_BUDAT > '2022-01-01';
