SELECT DISTINCT
  LIN.BWKEY AS Centro,
  PED.AUART AS Documentos_Vendas, 
  PED.KUNNR AS ID_Externo, 
  CLI.NAME1 AS Cliente,
  PED.ERDAT AS Data_Pedido, 
  NF.PSTDAT AS Data_NF,
  PED.NETWR AS Valor_Pedido,
  NF.NFTOT AS Valor_NF,
  (NF.NFTOT - PED.NETWR) AS Dif_Valor,
--  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) AS Vendedor  
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin 
  ON lin.xped = item.vbeln 
  AND lin.matnr = item.matnr 
  AND lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf 
  ON lin.mandt = nf.mandt 
  AND lin.docnum = nf.docnum
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS cli 
  ON ped.mandt = cli.mandt 
  AND ped.kunnr = cli.kunnr
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv 
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend 
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE
  ped.erdat BETWEEN '2025-01-01' AND '2025-04-30'
  AND ped.auart IN ('OR1', 'ZPDV', 'ZCAS')  
  AND ped.abstk = 'A'
  AND nf.parid > '1000000000'
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
	AND nf.direct = '2' 
  AND nf.nftype = 'YC'
  AND (NF.NFTOT - PED.NETWR) > 0
ORDER BY 
  NF.PSTDAT