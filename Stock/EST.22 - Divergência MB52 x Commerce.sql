SELECT DISTINCT
  ATP.DEPOSITO AS Centro,
  ATP.SKU AS Material,
  TEX.MAKTX AS Texto_Breve_Material,
  ATP.QTD_ESTOQUE AS QTD_Estoque,
  ATP.RESERVADO AS Reservado,
  ATP.QTD_DISPONIVEL_ATP AS QTD_Real,
  CMC.AVAIL AS Quantidade_Commerce,
  CMC.AVAIL - QTD_DISPONIVEL_ATP AS Divergencia_Final
FROM 
  `production-servers-magnumtires.prdmgm_views.estoque_atp` AS ATP
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.zsdt_0019` AS CMC
  ON ATP.DEPOSITO = CMC.WERKS
  AND ATP.SKU = RIGHT(CMC.MATNR, 6)
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard` AS POS
  ON CMC.WERKS = POS.WERKS
  AND CMC.LGORT = POS.LGORT
  AND CMC.MATNR = POS.MATNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS TEX 
  ON POS.MATNR = TEX.MATNR 
WHERE 
  CMC.AVAIL - QTD_DISPONIVEL_ATP <> 0