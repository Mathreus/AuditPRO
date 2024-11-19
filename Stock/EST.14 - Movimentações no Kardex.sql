SELECT 
  KDX.BUKRS AS Empresa,
  KDX.WERKS AS Centro,
  KDX.LGORT AS Deposito,
  KDX.SOBKZ AS EstoqueEspecial,
  KDX.CPUDT_MKPF AS DataMovimento,
  KDX.CPUTM_MKPF AS Hora,
  KDX.USNAM_MKPF AS Usuario,
  KDX.BWART AS TMv,
  CASE
    WHEN KDX.SHKZG = 'S' THEN 'Entrada'
    ELSE 'Saída'
  END Movimento,
  RIGHT(KDX.MATNR, 6) AS Material,
  TEX.MAKTX AS Texto_Breve_Material,
  KDX.MENGE AS Quantidade,
  (KDX.MENGE * VLR.VERPR) AS Montante,
  KDX.WEMPF AS Recebedor,
  KDX.SGTXT AS Texto,
  KDX.MBLNR AS DocMaterial
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg` as KDX
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` AS VLR ON
  KDX.WERKS = VLR.BWKEY AND
  KDX.MATNR = VLR.MATNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt` AS TEX ON
  KDX.MATNR = TEX.MATNR