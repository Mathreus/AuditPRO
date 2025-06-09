COM.10

SELECT DISTINCT
  LIN.BWKEY AS Centro,
  NF.PSTDAT AS Data_NF,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  NF.NFENUM AS NF_Faturada,
  RIGHT(LIN.MATNR, 6) AS Material_Faturamento,
  LIN.MAKTX AS Descricao_Material_Faturamento,
  NF.NFTOT AS Valor_Faturamento,
  DEV.PSTDAT AS Data_Devolucao,
  DEV.NFENUM AS NF_Devolucao,
  RIGHT(DEVLIN.MATNR, 6) AS Material_Devolvido,
  DEVLIN.MAKTX AS Descricao_Material_Devolvido,
  DEV.NFTOT AS Valor_Devolucao,
  DATE_DIFF(DEV.PSTDAT, NF.PSTDAT, DAY) AS DIF_DATA
FROM    
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
  ON NF.DOCNUM = LIN.DOCNUM 
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS DEV
  ON NF.PARID = DEV.PARID  -- Mesmos clientes
  AND NF.NAME1 = DEV.NAME1 -- Mesmo nome de cliente
  AND DEV.NFTYPE IN ('ZD', 'Y2') -- Tipos de nota fiscal que indicam devolução
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS DEVLIN
  ON DEV.DOCNUM = DEVLIN.DOCNUM
WHERE
  DEV.PSTDAT BETWEEN '2025-05-01' AND '2025-05-31'
  AND NF.PARID > '1000000000'
  AND DEV.NFENUM IS NOT NULL
  AND DEVLIN.MATNR = LIN.MATNR
  AND DATE_DIFF(DEV.PSTDAT, NF.PSTDAT, DAY) > 60
ORDER BY
  DATE_DIFF(DEV.PSTDAT, NF.PSTDAT, DAY) DESC