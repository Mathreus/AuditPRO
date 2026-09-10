SELECT DISTINCT
  B.BUKRS AS Empresa,
  EXTRACT(YEAR FROM B.H_BUDAT) AS Ano, 
  B.H_BUDAT AS Data_Lcto,
  B.LIFNR AS ID_Fornecedor,
  CASE
    WHEN B.SHKZG = 'S' THEN 'Débito'
    WHEN B.SHKZG = 'H' THEN 'Crédito'
    ELSE 'Nada'
  END AS Deb_Cred,
  BK.USNAM AS Usuario,
  B.HKONT AS Conta_Razao,
  KAT.TXT20 AS Descricao_Conta_Razao,
  B.BELNR AS Lcto_Contabil,
  B.H_BLART AS Tipo,
  B.WRBTR AS Montante,
  ACD.GKONT AS Conta_Contrapartida,
  KAT_CP.TXT20 AS Descricao_Conta_Contrapartida
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.acdoca` ACD
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B
  ON ACD.RBUKRS = B.BUKRS
  AND ACD.GJAHR = B.GJAHR
  AND ACD.BELNR = B.BELNR
  AND ACD.BUZEI = B.BUZEI
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bkpf` AS BK
  ON B.BUKRS = BK.BUKRS
  AND B.GJAHR = BK.GJAHR
  AND B.BELNR = BK.BELNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS KAT 
  ON B.HKONT = KAT.SAKNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.skat` AS KAT_CP 
  ON ACD.GKONT = KAT_CP.SAKNR
WHERE
  B.H_BUDAT BETWEEN '2025-01-01' AND '2025-01-31'
  AND B.H_BLART <> 'ES'
  AND B.AUGDT IS NOT NULL
  AND (LEFT(ACD.GKONT, 1) IN ('3', '4', '5'));