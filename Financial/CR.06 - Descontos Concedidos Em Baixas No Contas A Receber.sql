SELECT DISTINCT  
  FIN.BUKRS AS Empresa,
  FIN.H_BUDAT AS DataLcto,
  FIN.H_BLART AS Tipo_Lcto,
  CASE
    WHEN FIN.SHKZG = 'S' THEN 'Débito'
    ELSE 'Crédito'
  END Deb_Cred,
  FIN.BELNR AS NumDocumento,
  FIN.HKONT AS Conta_Contabil,
  FIN.DMBTR AS Montante
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as FIN
WHERE 
  (HKONT = '3020101003' OR HKONT = '3030402004' OR HKONT = '3030402005' OR HKONT = '3040302004' ) AND 
  H_BSTAT <> 'J' AND
  H_BUDAT BETWEEN '2024-07-01' AND '2024-07-31'