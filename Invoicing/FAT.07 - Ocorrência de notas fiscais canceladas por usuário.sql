SELECT
  CONCAT(LEFT(NF.BUKRS, 2), RIGHT(NF.BRANCH, 2)) AS Centro,
  MAX(NF.PSTDAT) AS DataLcto,
  MAX(NF.DIRECT) AS EntradaSaida,
  MAX(NF.PARID) AS ID_Externo,
  MAX(NF.NAME1) AS Cliente,
  MAX(NF.CNPJ_BUPLA) AS CNPJ,
  MAX(PED.VBELN) AS Pedido,
  NF.NFENUM AS NumeroNF,
  MAX(NF.CANCEL) AS Estorno,
  MAX(NF.CRENAM) AS Usuario,
  MAX(NF.NFTOT) AS Montante,
  MAX(RELV.PARTNER) as Cod_orig_vend, 
  MAX(CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1)) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as item ON
  ped.mandt = item.mandt AND
  ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` as fa ON
  ped.mandt = fa.mandt AND
  ped.vbeln = fa.vbelv AND
  vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` as fat ON
  fat.mandt = ped.mandt AND
  fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` as rp ON
  rp.mandt = ped.mandt AND
  fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` as lin ON
  lin.mandt = ped.mandt AND
  rp.vbeln = lin.refkey AND
  rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as nf ON
  nf.mandt = ped.mandt AND
  lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` as relv ON
  ped.mandt = relv.client AND 
  relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` as vend ON
  ped.mandt = vend.client AND
  relv.partner = vend.partner
WHERE
  NF.PSTDAT BETWEEN '2024-06-01' AND '2024-06-30' AND
--  NF.DIRECT = '2' AND
--  NF.PARID > '1000000000' AND
-- PED.ABSTK = 'A' AND
  NF.CANCEL = 'X'
GROUP BY
  NF.NFENUM,
  CONCAT(LEFT(NF.BUKRS, 2), RIGHT(NF.BRANCH, 2))
ORDER BY
  MAX(NF.NFTOT) ASC