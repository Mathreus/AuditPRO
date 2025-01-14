SELECT 
  CAD.LIFNR AS COD_FORNECEDOR,
  FORN.name1 AS FORNECEDOR,
  CAD.BANKL AS AGENCIA_CADASTRO,
  CAD.BANKN AS CONTA_CADASTRO,
  FORN.STCD1 AS CNPJ_CAD,
  FORN.STCD2 AS CPF_CAD,
  PG.ZBNKL AS AGENCIA_PG,
  PG.ZBNKN AS CONTA_PAGAMENTO,
  PG.STCD1 AS CPF_CNPJ_PG,
  PG.ZALDT AS DT_LANC_PG,
  PG.VALUT AS DT_EFETIVA,
  PG.RZAWE AS FORM_PG,
  PG.HKTID AS ID_BANCO,
  PG.HBKID AS BANCO_EMPRESA,
  PG.LAUFI AS PROGRAMA_PG,
  PG.VBLNR AS REF_PG,
  PG.RWBTR AS VALOR_PG,
  PG.ABSBU AS CENTRO_PG
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfbk` as CAD
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.reguh` as PG 
    ON CAD.LIFNR = PG.LIFNR
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as FORN
    ON CAD.LIFNR = FORN.LIFNR
  WHERE
--  PG.XVORL = 'X'
  PG.VALUT BETWEEN '2024-12-01' AND '2024-12-31'
  AND ( CAD.BANKL <> PG.ZBNKL OR CAD.BANKN <> PG.ZBNKN)
  AND PG.ZBNKL <> ''
  AND PG.ZBNKN <> ''