SELECT DISTINCT
  ITEM.WERKS AS Centro,
  PED.AUART AS Documentos_Vendas, 
  PED.KUNNR AS ID_Externo, 
  C.NAME1 AS Cliente,
  PED.VBELN AS Pedido,
  PED.ERDAT AS Data_Pedido,
  EXTRACT(YEAR FROM ped.erdat) AS Ano,
  CASE 
    WHEN EXTRACT(YEAR FROM ped.erdat) = 2024 THEN '3'
    WHEN EXTRACT(YEAR FROM ped.erdat) = 2025 THEN '5'
    ELSE '0'
  END Custo_Pedido,
  PED.NETWR AS Montante_Pedido, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) AS Vendedor  
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS C
  ON PED.KUNNR = C.KUNNR
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv 
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend 
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE
  PED.ERDAT BETWEEN '2024-01-01' AND '2025-04-30'
  AND PED.AUART IN ('OR1', 'ZPDV', 'ZCAS') 
  AND PED.ABSTK = 'C'
  AND PED.AUART IN ('OR1', 'ZPDV', 'ZCAS') 
