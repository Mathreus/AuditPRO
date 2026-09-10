WITH base AS (
  SELECT DISTINCT
    LIN.BWKEY AS Centro,
    NF.PSTDAT AS Dt_lan,
    CASE
      WHEN PED.SPART = '01' THEN 'Consumo'
      WHEN PED.SPART = '02' THEN 'Revenda'
      WHEN PED.SPART = '04' THEN 'Market Place'
      ELSE 'Nada'
    END AS Canal,
    NF.PARID AS ID_Externo,
    NF.NAME1 AS Cliente,
    NF.INCO2 AS Cidade_NF,
    CLI.ORT01 AS Cidade_Cadastro,
    NF.STRAS AS Rua_NF,
    CLI.STRAS AS Rua_Cadastro,
    NF.STKZN AS PF_PJ,
    PED.VBELN AS Pedido,
    NF.NFENUM AS Num_nfe,
    NF.NFTOT AS Valor_NF,
    RELV.PARTNER AS Cod_orig_vend,
    CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor,

    -- Normalização da cidade NF
    REGEXP_REPLACE(
      TRIM(
        TRANSLATE(
          UPPER(COALESCE(NF.INCO2, '')),
          'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
          'AAAAAEEEEIIIIOOOOOUUUUC'
        )
      ),
      r'\s+',
      ' '
    ) AS Cidade_NF_Norm,

    -- Normalização da cidade cadastro
    REGEXP_REPLACE(
      TRIM(
        TRANSLATE(
          UPPER(COALESCE(CLI.ORT01, '')),
          'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
          'AAAAAEEEEIIIIOOOOOUUUUC'
        )
      ),
      r'\s+',
      ' '
    ) AS Cidade_Cadastro_Norm,

    -- Normalização da rua NF
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        TRIM(
          TRANSLATE(
            UPPER(COALESCE(NF.STRAS, '')),
            'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
            'AAAAAEEEEIIIIOOOOOUUUUC'
          )
        ),
        r'[^A-Z0-9 ]',
        ''
      ),
      r'\s+',
      ' '
    ) AS Rua_NF_Norm,

    -- Normalização da rua cadastro
    REGEXP_REPLACE(
      REGEXP_REPLACE(
        TRIM(
          TRANSLATE(
            UPPER(COALESCE(CLI.STRAS, '')),
            'ÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ',
            'AAAAAEEEEIIIIOOOOOUUUUC'
          )
        ),
        r'[^A-Z0-9 ]',
        ''
      ),
      r'\s+',
      ' '
    ) AS Rua_Cadastro_Norm

  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM
      ON PED.MANDT = ITEM.MANDT
     AND PED.VBELN = ITEM.VBELN
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS FA
      ON PED.MANDT = FA.MANDT
     AND PED.VBELN = FA.VBELV
     AND FA.VBTYP_N = 'M'
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS FAT
      ON FAT.MANDT = PED.MANDT
     AND FA.VBELN = FAT.VBELN
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS RP
      ON RP.MANDT = PED.MANDT
     AND FAT.VBELN = RP.VBELN
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN
      ON LIN.MANDT = PED.MANDT
     AND RP.VBELN = LIN.REFKEY
     AND RP.MATNR = LIN.MATNR
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF
      ON NF.MANDT = PED.MANDT
     AND LIN.DOCNUM = NF.DOCNUM
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI
      ON NF.PARID = CLI.KUNNR
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV
      ON PED.MANDT = RELV.CLIENT
     AND RELV.IDNUMBER = ITEM.PERVE_ANA
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND
      ON PED.MANDT = VEND.CLIENT
     AND RELV.PARTNER = VEND.PARTNER
  WHERE
    NF.PSTDAT BETWEEN '2026-01-01' AND '2026-06-30'
    AND NF.PARID > '1000000000'
    AND NF.NFENUM <> 'NULL'
    AND NF.CANCEL <> 'X'
    AND NF.DIRECT = '2'
    AND NF.NFTYPE = 'YC'
    AND PED.ABSTK = 'A'
    AND PED.VBTYP = 'C'
)

SELECT
  Centro,
  Dt_lan,
  Canal,
  ID_Externo,
  Cliente,
  Cidade_NF,
  Cidade_Cadastro,
  CASE
    WHEN Cidade_NF_Norm = Cidade_Cadastro_Norm THEN 'IGUAL'
    ELSE 'DIVERGENTE'
  END AS Validacao_Cidade,
  Rua_NF,
  Rua_Cadastro,
  CASE
    WHEN Rua_NF_Norm = Rua_Cadastro_Norm THEN 'IGUAL'
    ELSE 'DIVERGENTE'
  END AS Validacao_Rua,
  CASE
    WHEN Cidade_NF_Norm = Cidade_Cadastro_Norm
     AND Rua_NF_Norm = Rua_Cadastro_Norm THEN 'CADASTRO ADERENTE'
    WHEN Cidade_NF_Norm <> Cidade_Cadastro_Norm
     AND Rua_NF_Norm <> Rua_Cadastro_Norm THEN 'CIDADE E RUA DIVERGENTES'
    WHEN Cidade_NF_Norm <> Cidade_Cadastro_Norm THEN 'SOMENTE CIDADE DIVERGENTE'
    WHEN Rua_NF_Norm <> Rua_Cadastro_Norm THEN 'SOMENTE RUA DIVERGENTE'
    ELSE 'NAO CLASSIFICADO'
  END AS Status_Cruzamento,
  PF_PJ,
  Pedido,
  Num_nfe,
  Valor_NF,
  Cod_orig_vend,
  Vendedor
FROM base;
