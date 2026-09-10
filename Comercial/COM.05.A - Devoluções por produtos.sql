WITH relv_unico AS (
  SELECT
    client,
    idnumber,
    partner
  FROM (
    SELECT
      client,
      idnumber,
      partner,
      ROW_NUMBER() OVER (
        PARTITION BY client, idnumber
        ORDER BY partner
      ) AS rn
    FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id`
  )
  WHERE rn = 1
)

SELECT DISTINCT
  LIN.BWKEY AS Centro,
  NF.PSTDAT AS DT_Dev,
  NF.PARID AS Id_Externo,
  NF.NAME1 AS Cliente,
  PED.VBELN AS Pedido,
  NF.NFENUM AS Num_nfe,
  RIGHT(LIN.MATNR, 6) AS Codigo,
  LIN.MAKTX AS Texto_Breve_Material,
  LIN.MENGE AS Quantidade,
  LIN.NETWR AS Valor_Produto,
  RELV.PARTNER AS Cod_orig_vend,
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM
  ON PED.MANDT = ITEM.MANDT
  AND PED.VBELN = ITEM.VBELN
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
  ON LIN.XPED = ITEM.VBELN
  AND LIN.MATNR = ITEM.MATNR
  AND LIN.ITMNUM = ITEM.POSNR
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
  ON LIN.MANDT = NF.MANDT
  AND LIN.DOCNUM = NF.DOCNUM
INNER JOIN 
  relv_unico AS RELV
  ON PED.MANDT = RELV.CLIENT
  AND RELV.IDNUMBER = ITEM.PERVE_ANA
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND
  ON PED.MANDT = VEND.CLIENT
  AND RELV.PARTNER = VEND.PARTNER
WHERE 
  NF.PSTDAT BETWEEN DATE '2026-06-01' AND DATE '2026-06-30'
  AND NF.PARID > '1000000000'
  AND PED.VBELN LIKE '%006%'
  AND NF.NFENUM IS NOT NULL
  AND NF.NFENUM <> 'NULL'
  AND NF.DIRECT = '1'
  AND NF.NATOP LIKE '%Dev.%'
  AND RELV.PARTNER = '9980002482'
  AND EXISTS (
    SELECT 1
    FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfe_active` AS ACT
    WHERE ACT.MANDT = NF.MANDT
      AND ACT.DOCNUM = NF.DOCNUM
  );
