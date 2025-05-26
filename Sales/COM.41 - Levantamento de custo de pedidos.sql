SELECT DISTINCT
  item.werks AS Centro,
  ped.auart AS Documentos_Vendas, 
  ped.erdat AS Data_Pedido,
  ped.AEDAT AS Data_Cancelamento,
  ped.kunnr AS ID_Externo, 
  C.name1 AS Cliente,
  PED.VBELN AS Pedido,
  PED.netwr AS Valor_Cancelamento,
  RELV.PARTNER AS Cod_orig_vend, 
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
  AND PED.ABSTK = 'C'
  AND PED.AUART IN ('OR1', 'ZPDV', 'ZCAS') 