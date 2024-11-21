WITH pedidos_duplicados AS (
  SELECT 
    CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) AS Centro,
    ARRAY_AGG(DISTINCT PED.VBELN) AS Pedidos,
    NF.NFENUM AS Num_nfe,
    NF.PARID AS Id_Externo, 
    NF.NAME1 AS Cliente,    
    NF.NFTOT AS Montante, 
    CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor 
  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
  INNER JOIN  
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
    ped.mandt = item.mandt AND
    ped.vbeln = item.vbeln
  INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS fa ON
    ped.mandt = fa.mandt AND 
    ped.vbeln = fa.vbelv AND
    vbtyp_n = 'M'
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS fat ON
    fat.mandt = ped.mandt AND
    fa.vbeln = fat.vbeln
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS rp ON
    rp.mandt = ped.mandt AND
    fat.vbeln = rp.vbeln
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
    lin.mandt = ped.mandt AND
    rp.vbeln = lin.refkey AND
    rp.matnr = lin.matnr
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
    nf.mandt = ped.mandt AND
    lin.docnum = nf.docnum
  INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv on
  ped.mandt = relv.client and
  relv.idnumber = item.perve_ana
  INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client and
  relv.partner = vend.partner
  WHERE
    nf.pstdat BETWEEN '2024-01-01' AND '2024-10-31' 
    AND nf.parid > '1000000000'
    AND nf.nfenum <> 'NULL' 
    AND ped.abstk = 'A'
    AND nf.cancel <> 'X'   
    AND nf.direct = '2' 
    AND nf.natop LIKE '%Vnd.mer.adq%'
  GROUP BY
    CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)),
    NF.NFENUM,
    NF.PARID,
    NF.NAME1,
    NF.NFTOT,
    CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1)
  HAVING 
    ARRAY_LENGTH(Pedidos) > 1
)
SELECT 
  Centro,
  Id_Externo,
  Cliente,
  Pedido,
  Num_nfe,
  Montante,
  Vendedor
FROM
  pedidos_duplicados, UNNEST(Pedidos) AS Pedido
ORDER BY
  Num_nfe ASC, Centro ASC, Pedido ASC;