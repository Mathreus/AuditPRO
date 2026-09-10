-- Teste de auditoria:
-- Tempo entre entrada no Porto/DREC e entrada no depósito vendável/DREV
-- Regra ajustada:
-- O processo da MKPF.FRBNR é considerado apenas na entrada 101 do DREC.
-- As etapas 311 são vinculadas ao processo por material, centro, quantidade e cronologia.

--              ORDENAÇÃO:
-- 1) DREC | 101 | WE | IMPORT_C/I | QTD + |
-- 2) DREC | 311 | WA | IMPORT_C/I | QTD - |
-- 3) DREV | 311 | WA | COMERC_C/I | QTD + |

WITH movimentos_base AS (
  SELECT
    KDX.MANDT,
    KDX.WERKS AS Centro,
    KDX.MATNR AS Material,
    RIGHT(KDX.MATNR, 6) AS Codigo_Material,

    KDX.LGORT AS Deposito,
    KDX.BWART AS Tipo_Movimento,
    KDX.VGART_MKPF AS Tipo_Transacao,
    KDX.BWTAR AS Tipo_Avaliacao,

    KDX.MBLNR AS Doc_Material,
    KDX.MJAHR AS Ano_Documento,
    KDX.ZEILE AS Item_Documento,

    CAST(KDX.BUDAT_MKPF AS DATE) AS Data_Lcto,

    DATETIME(
      CAST(KDX.BUDAT_MKPF AS DATE),
      COALESCE(
        SAFE.PARSE_TIME(
          '%H%M%S',
          LPAD(
            REGEXP_REPLACE(CAST(KDX.CPUTM_MKPF AS STRING), r'[^0-9]', ''),
            6,
            '0'
          )
        ),
        TIME '00:00:00'
      )
    ) AS DataHora_Lcto,

    NULLIF(TRIM(MK.FRBNR), '') AS Processo,

    KDX.SHKZG,

    CASE
      WHEN KDX.SHKZG = 'S' THEN 'Entrada'
      WHEN KDX.SHKZG = 'H' THEN 'Saída'
      ELSE 'Verificar'
    END AS Movimentacao,

    KDX.MENGE AS QTD_Original,

    CASE
      WHEN KDX.SHKZG = 'S' THEN KDX.MENGE
      WHEN KDX.SHKZG = 'H' THEN KDX.MENGE * -1
      ELSE 0
    END AS QTD_Com_Sinal,

    ABS(KDX.MENGE) AS QTD_Abs,

    -- Valor da linha do documento de material
    KDX.DMBTR AS Valor,

    KDX.CHARG AS Lote

  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mseg` AS KDX

  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mkpf` AS MK
    ON KDX.MANDT = MK.MANDT
    AND KDX.MBLNR = MK.MBLNR
    AND KDX.MJAHR = MK.MJAHR

  WHERE
    CAST(KDX.BUDAT_MKPF AS DATE) >= DATE '2026-06-01'
    AND CAST(KDX.BUDAT_MKPF AS DATE) < DATE '2026-06-30'

    AND (
      (
        -- Entrada no Porto / DREC
        KDX.LGORT = 'DREC'
        AND KDX.BWART = '101'
        AND KDX.VGART_MKPF = 'WE'
        AND KDX.SHKZG = 'S'
      )
      OR
      (
        -- Saída do DREC
        KDX.LGORT = 'DREC'
        AND KDX.BWART = '311'
        AND KDX.VGART_MKPF = 'WA'
        AND KDX.BWTAR = 'IMPORT_C/I'
        AND KDX.SHKZG = 'H'
      )
      OR
      (
        -- Entrada no DREV
        KDX.LGORT = 'DREV'
        AND KDX.BWART = '311'
        AND KDX.VGART_MKPF = 'WA'
        AND KDX.BWTAR = 'COMERC_C/I'
        AND KDX.SHKZG = 'S'
      )
    )
),

entrada_drec_101_todas AS (
  SELECT
    *
  FROM
    movimentos_base
  WHERE
    Deposito = 'DREC'
    AND Tipo_Movimento = '101'
    AND Tipo_Transacao = 'WE'
    AND SHKZG = 'S'
),

entrada_drec_101_processo AS (
  SELECT
    *
  FROM
    entrada_drec_101_todas
  WHERE
    Tipo_Avaliacao = 'IMPORT_C/I'
    AND Processo IS NOT NULL
),

saida_drec_311 AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY
        MANDT,
        Centro,
        Material,
        Doc_Material,
        Ano_Documento,
        QTD_Abs
      ORDER BY
        Item_Documento
    ) AS RN_Par_311
  FROM
    movimentos_base
  WHERE
    Deposito = 'DREC'
    AND Tipo_Movimento = '311'
    AND Tipo_Transacao = 'WA'
    AND Tipo_Avaliacao = 'IMPORT_C/I'
    AND SHKZG = 'H'
),

entrada_drev_311 AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY
        MANDT,
        Centro,
        Material,
        Doc_Material,
        Ano_Documento,
        QTD_Abs
      ORDER BY
        Item_Documento
    ) AS RN_Par_311
  FROM
    movimentos_base
  WHERE
    Deposito = 'DREV'
    AND Tipo_Movimento = '311'
    AND Tipo_Transacao = 'WA'
    AND Tipo_Avaliacao = 'COMERC_C/I'
    AND SHKZG = 'S'
),

transferencia_drec_drev AS (
  SELECT
    S.MANDT,
    S.Centro,
    S.Material,
    S.Codigo_Material,

    S.Lote AS Lote_DREC,
    E.Lote AS Lote_DREV,

    S.Doc_Material AS Doc_Transferencia,
    S.Ano_Documento AS Ano_Transferencia,

    S.Data_Lcto AS Data_Saida_DREC,
    S.DataHora_Lcto AS DataHora_Saida_DREC,

    E.Data_Lcto AS Data_Entrada_DREV,
    E.DataHora_Lcto AS DataHora_Entrada_DREV,

    S.QTD_Com_Sinal AS QTD_Saida_DREC,
    E.QTD_Com_Sinal AS QTD_Entrada_DREV,
    S.QTD_Abs AS QTD_Transferida,

    -- Valores das etapas 311
    S.Valor AS Valor_Saida_DREC,
    E.Valor AS Valor_Entrada_DREV

  FROM
    saida_drec_311 AS S

  INNER JOIN
    entrada_drev_311 AS E
    ON S.MANDT = E.MANDT
    AND S.Centro = E.Centro
    AND S.Material = E.Material
    AND S.Doc_Material = E.Doc_Material
    AND S.Ano_Documento = E.Ano_Documento
    AND S.QTD_Abs = E.QTD_Abs
    AND S.RN_Par_311 = E.RN_Par_311
),

fluxo_candidato AS (
  SELECT
    EP.MANDT,
    EP.Centro,
    EP.Material,
    EP.Codigo_Material,
    EP.Processo,

    EP.Lote AS Lote_Entrada_DREC,
    TR.Lote_DREC,
    TR.Lote_DREV,

    EP.Doc_Material AS Doc_Entrada_DREC,
    EP.Ano_Documento AS Ano_Entrada_DREC,
    EP.Item_Documento AS Item_Entrada_DREC,
    EP.Data_Lcto AS Data_Entrada_DREC,
    EP.DataHora_Lcto AS DataHora_Entrada_DREC,

    TR.Doc_Transferencia,
    TR.Ano_Transferencia,
    TR.Data_Saida_DREC,
    TR.DataHora_Saida_DREC,
    TR.Data_Entrada_DREV,
    TR.DataHora_Entrada_DREV,

    EP.QTD_Com_Sinal AS QTD_Entrada_DREC,
    TR.QTD_Saida_DREC,
    TR.QTD_Entrada_DREV,
    TR.QTD_Transferida,

    -- Valores das três etapas do fluxo
    EP.Valor AS Valor_Entrada_DREC,
    TR.Valor_Saida_DREC,
    TR.Valor_Entrada_DREV,

    (
      SELECT
        COUNT(1)
      FROM
        entrada_drec_101_todas AS EN
      WHERE
        EN.MANDT = EP.MANDT
        AND EN.Centro = EP.Centro
        AND EN.Material = EP.Material
        AND EN.QTD_Abs = EP.QTD_Abs
        AND EN.Processo IS NULL
        AND EN.DataHora_Lcto > EP.DataHora_Lcto
        AND EN.DataHora_Lcto < TR.DataHora_Saida_DREC
    ) AS QTD_Entradas_Normais_Entre

  FROM
    entrada_drec_101_processo AS EP

  INNER JOIN
    transferencia_drec_drev AS TR
    ON EP.MANDT = TR.MANDT
    AND EP.Centro = TR.Centro
    AND EP.Material = TR.Material

    -- Mesma quantidade da entrada 101 com processo e da transferência 311
    AND EP.QTD_Abs = TR.QTD_Transferida

    -- Ordem cronológica correta
    AND EP.DataHora_Lcto <= TR.DataHora_Saida_DREC

    -- Lote ajuda a qualificar o vínculo, mas não elimina registros sem lote
    AND (
      COALESCE(EP.Lote, '') = COALESCE(TR.Lote_DREC, '')
      OR COALESCE(EP.Lote, '') = ''
      OR COALESCE(TR.Lote_DREC, '') = ''
    )
),

fluxo_vinculado AS (
  SELECT
    *
  FROM
    fluxo_candidato

  WHERE
    QTD_Entradas_Normais_Entre = 0

  QUALIFY
    -- Para cada transferência 311, pega a entrada 101 com processo mais próxima anterior
    ROW_NUMBER() OVER (
      PARTITION BY
        MANDT,
        Centro,
        Material,
        Doc_Transferencia,
        Ano_Transferencia,
        QTD_Transferida
      ORDER BY
        DataHora_Entrada_DREC DESC,
        Doc_Entrada_DREC DESC,
        Item_Entrada_DREC DESC
    ) = 1

    AND

    -- Para cada entrada 101 com processo, pega a primeira transferência posterior
    ROW_NUMBER() OVER (
      PARTITION BY
        MANDT,
        Centro,
        Material,
        Processo,
        Doc_Entrada_DREC,
        Ano_Entrada_DREC,
        Item_Entrada_DREC,
        QTD_Entrada_DREC
      ORDER BY
        DataHora_Saida_DREC ASC,
        Doc_Transferencia ASC
    ) = 1
),

texto_material AS (
  SELECT
    MATNR AS Material,
    ANY_VALUE(MAKTX) AS Texto_Breve_Material
  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.makt`
  GROUP BY
    MATNR
)

SELECT
  FV.Centro,
  FV.Processo,

  FV.Codigo_Material,
  FV.Material,
  TEX.Texto_Breve_Material,

  FV.Lote_Entrada_DREC,
  FV.Lote_DREC,
  FV.Lote_DREV,

  FV.Doc_Entrada_DREC,
  FV.Data_Entrada_DREC,

  FV.Doc_Transferencia,
  FV.Data_Saida_DREC,
  FV.Data_Entrada_DREV,

  FV.QTD_Entrada_DREC,
  FV.QTD_Saida_DREC,
  FV.QTD_Entrada_DREV,

  -- Valores retornados no relatório
  FV.Valor_Entrada_DREC,
  FV.Valor_Saida_DREC,
  FV.Valor_Entrada_DREV,

  CASE
    WHEN FV.QTD_Entrada_DREC = FV.QTD_Transferida
     AND FV.QTD_Saida_DREC = FV.QTD_Transferida * -1
     AND FV.QTD_Entrada_DREV = FV.QTD_Transferida
    THEN 'Quantidade OK'
    ELSE 'Verificar quantidade'
  END AS Validacao_Quantidade,

  CASE
    WHEN FV.QTD_Entradas_Normais_Entre = 0
    THEN 'Vínculo limpo com processo da entrada 101'
    ELSE 'Verificar: existe entrada normal entre o processo e a transferência'
  END AS Validacao_Processo,

  CASE
    WHEN FV.Valor_Entrada_DREC = FV.Valor_Saida_DREC
     AND FV.Valor_Saida_DREC = FV.Valor_Entrada_DREV
    THEN 'Valor OK'
    ELSE 'Verificar valor'
  END AS Validacao_Valor,

  DATE_DIFF(
    FV.Data_Entrada_DREV,
    FV.Data_Entrada_DREC,
    DAY
  ) AS Dias_Entrada_DREC_ate_DREV,

  DATETIME_DIFF(
    FV.DataHora_Entrada_DREV,
    FV.DataHora_Entrada_DREC,
    HOUR
  ) AS Horas_Entrada_DREC_ate_DREV,

  DATETIME_DIFF(
    FV.DataHora_Saida_DREC,
    FV.DataHora_Entrada_DREC,
    HOUR
  ) AS Horas_Permanencia_DREC,

  DATETIME_DIFF(
    FV.DataHora_Entrada_DREV,
    FV.DataHora_Saida_DREC,
    HOUR
  ) AS Horas_Transferencia_DREC_DREV

FROM
  fluxo_vinculado AS FV

LEFT JOIN
  texto_material AS TEX
  ON FV.Material = TEX.Material

ORDER BY
  Dias_Entrada_DREC_ate_DREV DESC,
  Horas_Entrada_DREC_ate_DREV DESC,
  FV.Processo,
  FV.Codigo_Material;
