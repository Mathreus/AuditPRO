SELECT DISTINCT
  LIN.BWKEY AS Centro,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  PED.ERDAT AS Data_Pedido,
  REM.ERDAT AS Data_Remessa,
  NF.PSTDAT AS Data_NF,
  PED.VBELN AS Pedido,
  REM.VBELN AS Remessa,
--  NF.DIRECT AS DirecaoNF,
  LIN.CFOP,
  NF.NFENUM AS Num_NF,
  RIGHT(LIN.matnr, 6) AS Codigo_material, 
  LIN.MAKTX AS Texto_Breve_Material,
  LIN.MENGE AS QTD,
  LIN.NETWR AS Valor,
--  NF.NFTOT AS Faturamento,
  NF.NFTYPE AS Natureza,
  NF.NATOP AS Referencia,
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
LEFT JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM 
  ON ped.mandt = rem.mandt 
  AND item.vbeln = rem.vgbel 
  AND item.posnr = rem.vgpos
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN 
  ON lin.xped = item.vbeln 
  AND lin.matnr = item.matnr 
  AND lin.itmnum = item.posnr 
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
  ON lin.mandt = nf.mandt 
  AND lin.docnum = nf.docnum
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI
  ON ped.mandt = cli.mandt 
  AND ped.kunnr = cli.kunnr
LEFT JOIN 
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
	ON ped.mandt = relv.client 
	AND relv.idnumber = item.perve_ana
LEFT JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
	ON ped.mandt = vend.client 
	AND relv.partner = vend.partner
WHERE
  NF.PSTDAT BETWEEN '2024-01-01' AND '2025-05-30' 
  AND NF.PARID IN ('1000120770', '1000085876', '1000059152', '1000159084', '1000163133', '1000163210', '1000163607', '1000144146', '1000170951')  
  AND PED.AUART = 'ZRDE'
  AND NF.DIRECT = '2' 
  AND PED.ABSTK = 'A' 
ORDER BY  
  NF.NFENUM DESC