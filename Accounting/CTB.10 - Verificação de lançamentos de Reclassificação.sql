SELECT
  CTB.BUKRS as Empresa,
  CTB.H_BUDAT AS Data_Lcto,
  CTB.BELNR as Num_Documento,
  CTB.HKONT AS Conta_Contabil,
  CASE
    WHEN CTB.SHKZG = 'S' THEN 'Débito'
    WHEN CTB.SHKZG = 'H' THEN 'Crédito'
    ELSE 'Nada'
  END Deb_Cred,
  CTB.H_BLART AS Tipo,
  CTB.DMBTR AS Montante,
  CTB.SGTXT AS Texto
FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS CTB
WHERE
  CTB.H_BUDAT BETWEEN '2024-01-01' AND '2024-10-31'
  AND CTB.SGTXT LIKE '%RECLASS%'