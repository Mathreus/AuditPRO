SELECT DISTINCT
  RIGHT(EKO.LIFNR, 4) AS ID_Fornecedor,
  EKO.INCO2 AS Fornecedor,
  EKO.AEDAT AS Data_Criacao,
  EKO.BSART AS Tipo_Compra,
  EKO.EBELN AS Pedido_Intermcompany,
  ITEM.WERKS AS Centro_Cliente,
  PED.ERDAT AS Data_Pedido_Cliente,
  CASE
    WHEN PED.SPART = '01' THEN 'Consumo'
    WHEN PED.SPART = '02' THEN 'Revenda'
    WHEN PED.SPART = '04' THEN 'Marketplace'
    ELSE 'Não Identificado'
  END AS Canal_Cliente,
  PED.AUART AS Tipo_Venda_Cliente,
  PED.KUNNR AS ID_Cliente,
  NF.NAME1 AS Cliente,
  PED.VBELN AS Pedido_Cliente,
  PED.NETWR AS Valor_Pedido_Cliente,
  NF.PSTDAT AS Data_NF_Cliente,
  NF.NFENUM AS Num_NF_Cliente,
  NF.NFTOT AS Montante_NF_Cliente,
--  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) AS Vendedor,  
  DATE_DIFF(NF.PSTDAT, EKO.AEDAT, DAY) AS DIF_DIAS
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
LEFT JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON PED.mandt = ITEM.mandt 
  AND PED.vbeln = ITEM.vbeln
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN 
  ON LIN.xped = ITEM.vbeln 
  AND LIN.matnr = ITEM.matnr 
  AND LIN.itmnum = ITEM.posnr 
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF 
  ON LIN.mandt = NF.mandt 
  AND LIN.docnum = NF.docnum
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS BFA
  ON PED.VBELN = BFA.vbelv
  AND BFA.VBTYP_N = 'V'
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.ekko` AS EKO
  ON BFA.VBELN = EKO.EBELN
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.ekbe` AS EKE
  ON EKO.EBELN = EKE.EBELN
LEFT JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE
  EKO.AEDAT BETWEEN '2025-01-01' AND '2025-04-30'
  AND EKO.BSART = 'ZINT' -- Trazer apenas Intercompany
  AND EKO.LIFNR BETWEEN '0000001000' AND '0000001999' -- Puxar apenas as IMPORTADORAS
  AND EKO.BSTYP = 'F' -- Puxar apenas pedidos
  AND PED.AUART = 'ZCAS'
  AND PED.ABSTK = 'A'
  AND (NF.CANCEL IS NULL OR NF.CANCEL <> 'X')
  AND (
    (EKO.LIFNR = '0000001002' AND DATE_DIFF(NF.PSTDAT, EKO.AEDAT, DAY) > 10)
    OR
    (EKO.LIFNR = '0000001004' AND DATE_DIFF(NF.PSTDAT, EKO.AEDAT, DAY) > 30)
  );