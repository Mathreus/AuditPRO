SELECT DISTINCT
	LIN.BWKEY as Centro,
	NF.PSTDAT as DT_Lcto,
  CASE
  	WHEN ped.spart = '01' THEN 'Consumo'
  	WHEN ped.spart = '02' THEN 'Revenda'
    WHEN PED.SPART = '04' THEN 'MarketPlace' 
  	ELSE 'Outros'
  END Canal,
  NF.PARID as ID_Externo,
	CLI.NAME1 as Cliente,
  NF.CNPJ_BUPLA AS CNPJ,
	PED.VBELN as Pedido,
  NF.DIRECT AS Direcao_NF,
  NF.NFTYPE AS Tipo_NF,
  NF.MODEL AS Modelo,
  NF.SERIES AS Serie,
	NF.NFENUM as Num_nfe,
  PED.NETWR AS Valor_Liquido_NF,  
	NF.NFTOT as Valor_Total_NF,
  NF.NATOP AS Referencia,
	RELV.PARTNER as Cod_orig_vend, 
	CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) as Vendedor
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS FA 
  ON ped.mandt = fa.mandt  
  AND ped.vbeln = fa.vbelv 
  AND vbtyp_n = 'M'
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS FAT 
  ON fat.mandt = ped.mandt 
  AND fa.vbeln = fat.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS RP
  ON rp.mandt = ped.mandt 
  AND fat.vbeln = rp.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
  ON lin.mandt = ped.mandt 
  AND rp.vbeln = lin.refkey 
  AND rp.matnr = lin.matnr
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF 
  ON nf.mandt = ped.mandt 
  AND lin.docnum = nf.docnum
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI 
  ON PED.MANDT = CLI.MANDT
  AND NF.PARID = CLI.KUNNR
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE
  NF.PSTDAT BETWEEN '2025-10-01' and '2026-04-16' 
  AND PED.AUART IN ('ZOML', 'ZMLU', 'ZRML')
  
--  AND PED.KUNNR IN ('1000415674', '1000451228')
--  AND PED.GBSTK = 'C'
