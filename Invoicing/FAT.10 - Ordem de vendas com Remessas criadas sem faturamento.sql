SELECT DISTINCT
  item.werks AS Centro,
  ped.auart AS Documentos_Vendas, 
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda' 
    ELSE 'Não identificado'
  END Canal,
  ped.LAST_CHANGED_BY_USER AS Usuario,
  ped.kunnr AS ID_Externo, 
  cli.name1 AS Cliente,
  ped.erdat AS DataPedido,
  rem.erdat AS DataRemessa,
  RIGHT(ped.vbeln, 7) AS Pedido, 
  REM.vbeln AS Remessa,
  RIGHT(item.matnr, 6) AS Codigo_Material, 
  item.arktx AS Material,
  item.kwmeng AS QTD_Ordem, 
  item.netwr AS Valor_Pedido,
  fa.vbeln as DOC_FAT,
  RELV.PARTNER AS Cod_Vendedor, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor  
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM ON 
  item.vbeln = rem.vgbel and
  item.posnr = rem.vgpos
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS FA ON 
  rem.vbeln = fa.vbelv AND 
  rem.posnr = fa.posnv AND 
  FA.vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001w` AS CEN ON
  CEN.MANDT = REM.MANDT AND
  CEN.WERKS = REM.WERKS
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as cli on
  ped.mandt = cli.mandt and
  ped.kunnr = cli.kunnr
INNER JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
	ped.mandt = relv.client and
	relv.idnumber = item.perve_ana
INNER JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend on
	ped.mandt = vend.client and
	relv.partner = vend.partner
WHERE
--  item.werks IN ('2007', '2011', '2022', '2024', '2802', '2803')
  ped.auart <> 'ZCAS'
  AND fa.vbeln is null 
  AND ped.abstk = 'A' 
  AND ped.auart in ( 'OR1','ZCAS','ZPDV') 
  AND ped.erdat > '2020-01-01'
  AND DATE_DIFF(CURRENT_DATE(), REM.ERDAT, DAY) > 3
