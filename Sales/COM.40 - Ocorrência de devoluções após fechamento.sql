SELECT DISTINCT
  LIN.BWKEY AS Centro,
  NF.PSTDAT AS Data_NF,
  DEV.PSTDAT AS Data_Devolucao,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  NF.NFENUM AS NF_Faturada,
  RIGHT(LIN.MATNR, 6) AS Material_Faturamento,
  LIN.MAKTX AS Descricao_Material_Faturamento,
  LIN.MENGE AS Quantidade,
  LIN.NETWR AS Valor_Produto,
  NF.NFTOT AS Valor_Total_NF,
  DEV.NFENUM AS NF_Devolucao,
  RIGHT(DEVLIN.MATNR, 6) AS Material_Devolvido,
  DEVLIN.MAKTX AS Descricao_Material_Devolvido,
  DEVLIN.NETWR AS Valor_Produto_Devolucao,
  DEV.NFTOT AS Valor_Devolucao
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
WHERE
  NF.PSTDAT BETWEEN '2025-06-23' AND '2025-06-30'
  AND DEV.PSTDAT BETWEEN '2025-07-01' AND '2025-07-07'
  AND NF.PARID > '1000000000'
  AND DEV.NFENUM IS NOT NULL
  AND DEVLIN.MATNR = LIN.MATNR
