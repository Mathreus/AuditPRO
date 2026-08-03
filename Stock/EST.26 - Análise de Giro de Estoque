SELECT
  Centro,
  Deposito,
  Tipo_Movimento,
  Movimentacao,
  Criterio_Data,
  Codigo_Material,
  Texto_Breve_Material,
  QTD_Total,
  Valor,
  Data_Maxima,
  Data_Hoje,
  DATE_DIFF(Data_Hoje, Data_Maxima, DAY) AS Dias_Sem_Movimento,
  RN

FROM (
  SELECT
    KDX.WERKS AS Centro,
    KDX.LGORT AS Deposito,
    KDX.BWART AS Tipo_Movimento,
    RIGHT(KDX.MATNR, 6) AS Codigo_Material,
    TEX.MAKTX AS Texto_Breve_Material,

    CASE
      WHEN KDX.SHKZG = 'H' THEN 'Saída'
      WHEN KDX.SHKZG = 'S' THEN 'Entrada'
      ELSE 'Verificar'
    END AS Movimentacao,

    CASE
      WHEN KDX.SHKZG = 'H' THEN 'Data da última saída'
      WHEN KDX.SHKZG = 'S' THEN 'Data da entrada — material sem saída'
      ELSE 'Verificar'
    END AS Criterio_Data,

    KDX.BUDAT_MKPF AS Data_Maxima,

    CURRENT_DATE('America/Recife') AS Data_Hoje,

    (POS.LABST + POS.SPEME) AS QTD_Total,

    (POS.LABST + POS.SPEME) *
    MAX(
      COALESCE(
        NULLIF(VLR.VERPR, 0),
        NULLIF(VLR.STPRS, 0),
        0
      )
    ) AS Valor,

    ROW_NUMBER() OVER (
      PARTITION BY
        KDX.WERKS,
        KDX.LGORT,
        KDX.MATNR

      ORDER BY
        CASE
          WHEN KDX.SHKZG = 'H' THEN 1
          WHEN KDX.SHKZG = 'S' THEN 2
          ELSE 3
        END,

        KDX.BUDAT_MKPF DESC,
        KDX.CPUTM_MKPF DESC
    ) AS RN

  FROM 
    production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg AS KDX

  INNER JOIN 
    production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mkpf AS PF
      ON KDX.MBLNR = PF.MBLNR
     AND KDX.MJAHR = PF.MJAHR

  INNER JOIN
    production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mard AS POS
      ON KDX.WERKS = POS.WERKS
     AND KDX.LGORT = POS.LGORT
     AND KDX.MATNR = POS.MATNR

  INNER JOIN
    production-servers-magnumtires.prdmgm_sap_cdc_processed.makt AS TEX 
      ON POS.MATNR = TEX.MATNR 

  INNER JOIN
    production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew AS VLR
      ON POS.WERKS = VLR.BWKEY
     AND POS.MATNR = VLR.MATNR

  WHERE
    KDX.WERKS IN ('2012', '2006')
    AND KDX.LGORT = 'DREV'
    AND KDX.BWART NOT IN ('343','344')

    -- Considera tanto entradas quanto saídas
    AND KDX.SHKZG IN ('H', 'S')

    --AND KDX.BUDAT_MKPF > '2022-01-01'
    AND (POS.LABST + POS.SPEME) <> 0

  GROUP BY
    KDX.WERKS,
    KDX.LGORT,
    KDX.BWART,
    KDX.SHKZG,
    KDX.MATNR,
    TEX.MAKTX,
    POS.LABST,
    POS.SPEME,
    KDX.BUDAT_MKPF,
    KDX.CPUTM_MKPF
)

WHERE 
  DATE_DIFF(Data_Hoje, Data_Maxima, DAY) > 365
  AND RN = 1

ORDER BY
  Dias_Sem_Movimento DESC;
