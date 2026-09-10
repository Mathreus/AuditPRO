
SELECT DISTINCT
  LEFT(ped.vkbur, 2) AS Estado,
  item.werks AS Centro,
  ped.auart AS Documentos_Vendas, 
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    ELSE 'Revenda'
  END SetorAtividade,
  ped.LAST_CHANGED_BY_USER AS Usuario,
  ped.kunnr AS ID_Externo, 
  cli.name1 AS Cliente,
  ped.erdat AS DataPedido,
  ped.aedat AS DataCancelamento,
  DATE_DIFF(CAST(ped.aedat AS DATE), CAST(ped.erdat AS DATE), DAY) AS Diferenca_Dias,
  RIGHT(ped.vbeln, 7) AS Pedido, 
  RIGHT(item.matnr, 6) AS CodigoMaterial, 
  item.arktx AS Material,
  item.kwmeng AS QTD_Ordem, 
  item.netwr AS Valor_Pedido_Cancelado,
  RELV.PARTNER AS Cod_Vendedor, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor  
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
  lin.xped = item.vbeln AND
  lin.matnr = item.matnr AND
  lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
  lin.mandt = nf.mandt AND
  lin.docnum = nf.docnum
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS cli ON
  ped.mandt = cli.mandt AND
  ped.kunnr = cli.kunnr
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv ON
  ped.mandt = relv.client AND
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend ON
  ped.mandt = vend.client AND
  relv.partner = vend.partner
WHERE  
  ped.erdat BETWEEN '2025-03-01' AND '2025-03-31' AND 
  ped.auart IN ('OR1', 'ZPDV', 'ZCAS') AND
  ped.abstk = 'C'
ORDER BY 
  ped.erdat,
  cli.name1
