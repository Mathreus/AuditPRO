SELECT DISTINCT
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  CLI.ERDAT AS Data_Cadastro,
  MAX(NF.PSTDAT) AS Data_Lcto,
  DATE_DIFF(MAX(NF.PSTDAT), CLI.ERDAT, DAY) AS Diferenca_Dias,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda' 
    ELSE 'Nada'
  END AS Canal,
  NF.PARID AS Id_Externo,
  NF.NAME1 AS Cliente,
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
  ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS fa ON 
  ped.mandt = fa.mandt 
  AND ped.vbeln = fa.vbelv AND vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS fat ON 
  fat.mandt = ped.mandt
  AND fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS rp ON
  rp.mandt = ped.mandt 
  AND fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON 
  lin.mandt = ped.mandt 
  AND rp.vbeln = lin.refkey 
  AND rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON 
  nf.mandt = ped.mandt 
  AND lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv ON
  ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend ON 
  ped.mandt = vend.client 
  AND relv.partner = vend.partner
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS cli ON
  nf.parid = cli.kunnr
WHERE
--  DATE_DIFF((NF.PSTDAT), CLI.ERDAT, DAY) > 180
  nf.parid > '1000000000'
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
	AND nf.direct = '2' 
  AND nf.natop LIKE '%Vnd.mer.adq%'
  AND RELV.PARTNER = '9980000237'
GROUP BY
  nf.bukrs, nf.branch, cli.erdat, ped.spart, nf.parid, nf.name1, relv.partner, vend.bu_sort1, vend.bu_sort2; 