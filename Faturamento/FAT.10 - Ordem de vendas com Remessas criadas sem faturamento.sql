SELECT DISTINCT
  ITEM.WERKS AS Centro,
  CASE
    WHEN ITEM.WERKS IN ('2001', '2101', '2104', '2013', '2015', '2007', '2018', '2009', '2702', '2011', '3101', '2016', '2006', '3001', '2501', '2002', '2014', '2008') THEN 'Automático'
    ELSE 'Manual'
  END Faturamento_Automatico,
  ped.auart AS Documentos_Vendas, 
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda' 
    WHEN ped.spart = '04' THEN 'Marketplace'
    ELSE 'Não identificado'
  END Canal,
  ped.LAST_CHANGED_BY_USER AS Usuario,
  ped.kunnr AS ID_Externo, 
  cli.name1 AS Cliente,
  ped.erdat AS Data_Pedido,
  rem.erdat AS Data_Remessa,
  RIGHT(ped.vbeln, 7) AS Pedido, 
  REM.vbeln AS Remessa,
  RIGHT(item.matnr, 6) AS Codigo_Material, 
  item.arktx AS Material,
  item.kwmeng AS QTD_Ordem, 
  item.netwr AS Valor_Pedido,
  fa.vbeln as DOC_FAT,
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor  
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM  
  ON item.vbeln = rem.vgbel 
  AND item.posnr = rem.vgpos
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS FA  
  ON rem.vbeln = fa.vbelv  
  AND rem.posnr = fa.posnv  
  AND FA.vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001w` AS CEN 
  ON CEN.MANDT = REM.MANDT 
  AND CEN.WERKS = REM.WERKS
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI 
  ON ped.mandt = cli.mandt 
  AND ped.kunnr = cli.kunnr
INNER JOIN 
   `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
   ON ped.mandt = relv.client 
   AND relv.idnumber = item.perve_ana
INNER JOIN
   `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
    ON ped.mandt = vend.client 
    AND relv.partner = vend.partner
WHERE
  ped.auart <> 'ZCAS'
  AND fa.vbeln is null 
  AND ped.abstk = 'A' 
  AND ped.auart in ( 'OR1','ZCAS','ZPDV') 
  AND ped.erdat > '2020-01-01'
  AND DATE_DIFF(CURRENT_DATE(), REM.ERDAT, DAY) > 7
