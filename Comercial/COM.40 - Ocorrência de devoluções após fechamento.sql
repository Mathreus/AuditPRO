SELECT DISTINCT
  LIN.BWKEY AS Centro,
  NF.PSTDAT AS Data_NF,
  DEV.PSTDAT AS Data_Devolucao,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  PED.VBELN AS Pedido,
  NF.NFENUM AS NF_Faturada,
  RIGHT(LIN.MATNR, 6) AS Material_Faturamento,
  LIN.MAKTX AS Descricao_Material_Faturamento,
  LIN.MENGE AS Quantidade_NF,
  LIN.NETWR AS Valor_Produto,
  NF.NFTOT AS Valor_Total_NF,
  PED.VBELN AS Pedido_Devolucao,
  DEV.NFENUM AS NF_Devolucao,
  RIGHT(DEVLIN.MATNR, 6) AS Material_Devolvido,
  DEVLIN.MAKTX AS Descricao_Material_Devolvido,
  DEVLIN.MENGE AS QTD_Devolucao,
  DEVLIN.NETWR AS Valor_Produto_Devolucao,
  DEV.NFTOT AS Valor_Devolucao,
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(vend.bu_sort2,' ',vend.bu_sort1) as Vendedor,
  (DEVLIN.MENGE - LIN.MENGE) AS DIF_QTD,
  (DEVLIN.NETWR - LIN.NETWR) AS DIF_VALOR_PRODUTO,
  (DEV.NFTOT - NF.NFTOT) AS DIF_NF
FROM    
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
  ON NF.DOCNUM = LIN.DOCNUM 
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS DEV
  ON NF.PARID = DEV.PARID  
  AND NF.NAME1 = DEV.NAME1 
  AND DEV.NFTYPE IN ('ZD', 'Y2') 
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS DEVLIN
  ON DEV.DOCNUM = DEVLIN.DOCNUM
LEFT JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON DEVLIN.mandt = item.mandt 
  AND DEVLIN.XPED = ITEM.VBELN 
  AND DEVLIN.MATNR = ITEM.MATNR 
  AND devlin.itmnum = item.posnr 
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
  ON ITEM.MANDT = PED.MANDT  
  AND ITEM.VBELN = PED.VBELN 
LEFT JOIN 
   `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
    ON ped.mandt = relv.client 
    AND relv.idnumber = item.perve_ana
LEFT JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
     ON ped.mandt = vend.client 
     AND relv.partner = vend.partner
WHERE
  NF.PSTDAT BETWEEN '2025-06-23' AND '2025-06-30'
  AND DEV.PSTDAT BETWEEN '2025-07-01' AND '2025-07-07'
  AND NF.PARID > '1000000000'
  AND DEV.NFENUM IS NOT NULL
  AND DEVLIN.MATNR = LIN.MATNR
