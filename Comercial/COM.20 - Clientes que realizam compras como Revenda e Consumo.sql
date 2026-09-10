WITH ClientesComAmbosCanais AS (
  SELECT 
    KUNNR AS ID
  FROM (
    SELECT DISTINCT
      PED.KUNNR,
      PED.SPART
    FROM 
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
    INNER JOIN
      `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvp` AS KN
      ON PED.KUNNR = KN.KUNNR
    WHERE 
      KN.SPART IN ('01', '02') 
      AND KN.KUNNR > '1000000000' 
      AND PED.ABSTK = 'A'
      AND PED.SPART IN ('01', '02')
  )
  GROUP BY 
    KUNNR
  HAVING 
    COUNT(DISTINCT SPART) = 2
)

SELECT DISTINCT
  PED.ERDAT AS DT_Pedido,
  KN.KUNNR AS ID,
  CLI.NAME1 AS Cliente,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    WHEN PED.SPART = '02' THEN 'Revenda'
    WHEN PED.SPART = '04' THEN 'Marketplace'
    ELSE 'Não Identificado'
  END AS Canal, 
  PED.VBELN AS Pedido,
  PED.NETWR AS Valor_Pedido,
  RELV.PARTNER as Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) AS Vendedor
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvp` AS KN
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvv` AS VV
  ON KN.VKORG = VV.VKORG
  AND KN.KUNNR = VV.KUNNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI
  ON KN.KUNNR = CLI.KUNNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
  ON CLI.KUNNR = PED.KUNNR
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON PED.mandt = ITEM.mandt 
  AND PED.vbeln = ITEM.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
  ON PED.mandt = RELV.client 
  AND RELV.idnumber = ITEM.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
  ON PED.mandt = VEND.client 
  AND RELV.partner = VEND.partner
INNER JOIN
  ClientesComAmbosCanais AS CC
  ON KN.KUNNR = CC.ID
WHERE 
  KN.SPART IN ('01', '02') 
  AND KN.KUNNR > '1000000000' 
  AND PED.ABSTK = 'A'
ORDER BY
  KN.KUNNR