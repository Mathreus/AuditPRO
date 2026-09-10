WITH PedidosComMultiplasNF AS (
  SELECT 
    PED.VBELN AS Pedido,
    COUNT(DISTINCT NF.NFENUM) AS Qtde_NF_Diferentes,
    COUNT(DISTINCT NF.NFTYPE) AS Qtde_Tipos_NF,
    COUNT(DISTINCT CASE WHEN NF.NFTYPE = 'ZF' THEN NF.NFENUM END) AS Qtde_NF_ZF,
    COUNT(DISTINCT CASE WHEN NF.NFTYPE = 'YC' THEN NF.NFENUM END) AS Qtde_NF_YC,
    COUNT(DISTINCT NF.NFTOT) AS Qtde_Faturamentos_Distintos
  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
  INNER JOIN  
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
    ON PED.MANDT = ITEM.MANDT 
    AND PED.VBELN = ITEM.VBELN
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM 
    ON ITEM.VBELN = REM.VGBEL 
    AND ITEM.POSNR = REM.VGPOS
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS FAT
    ON REM.VBELN = FAT.VGBEL 
    AND REM.POSNR = FAT.VGPOS
  INNER JOIN  
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
    ON FAT.VBELN = LIN.REFKEY 
    AND FAT.POSNR = LIN.REFITM
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
    ON LIN.DOCNUM = NF.DOCNUM
  WHERE
    NF.PSTDAT BETWEEN '2025-02-01' AND '2025-02-28'
  GROUP BY PED.VBELN
  HAVING 
    COUNT(DISTINCT NF.NFENUM) > 1 -- Mais de uma nota fiscal
    AND COUNT(DISTINCT NF.NFTYPE) > 1 -- Pelo menos dois tipos de NF
    AND COUNT(DISTINCT CASE WHEN NF.NFTYPE = 'ZF' THEN NF.NFENUM END) > 0
    AND COUNT(DISTINCT CASE WHEN NF.NFTYPE = 'YC' THEN NF.NFENUM END) > 0
    AND COUNT(DISTINCT NF.NFTOT) = 1 -- Todas as notas têm o mesmo faturamento
)

SELECT DISTINCT
  CONCAT(LEFT(NF.BUKRS, 2), RIGHT(NF.BRANCH, 2)) AS Centro,
  NF.PSTDAT AS Data_lancamento,
  NF.CRETIM AS Horario,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    WHEN PED.SPART = '02' THEN 'Revenda'
    ELSE 'Não Identificado'
  END AS Canal,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
  PED.VBELN AS Pedido,
  PED.ABSTK AS Status_Pedido,
  NF.NFTYPE AS Tipo_NF,
  NF.NFENUM AS Num_nfe,
  NF.CANCEL AS Status_NF,
  NF.CRENAM AS Usuario,  
  NF.NFTOT AS Faturamento,
  NF.NATOP AS Referencia
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON PED.MANDT = ITEM.MANDT 
  AND PED.VBELN = ITEM.VBELN
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lips` AS REM 
  ON ITEM.VBELN = REM.VGBEL 
  AND ITEM.POSNR = REM.VGPOS
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS FAT
  ON REM.VBELN = FAT.VGBEL 
  AND REM.POSNR = FAT.VGPOS
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
  ON FAT.VBELN = LIN.REFKEY 
  AND FAT.POSNR = LIN.REFITM
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
  ON LIN.DOCNUM = NF.DOCNUM
INNER JOIN PedidosComMultiplasNF P
  ON PED.VBELN = P.Pedido
WHERE
  NF.PARID > '1000000000'
  AND PED.ABSTK = 'A' -- Pedido Ativo
  AND NF.NFTYPE IN ('YC', 'ZF')
  AND NF.CANCEL = ''
ORDER BY
  PED.VBELN ASC;