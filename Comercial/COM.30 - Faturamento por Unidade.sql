SELECT DISTINCT 
  PED.MANDT,
  PED.VKORG as EMPRESA,
  ITEM.WERKS as CENTRO,
  PED.VKBUR as ESCRITORIO_VENDAS,
  PED.VKGRP as EQUIPE_VENDAS,
  PED.ERDAT as DATA_CRIACAO,
  PED.AUART as DOC_VENDAS,
  PED.LAST_CHANGED_BY_USER as EMISSOR,
  PED.VBELN as PEDIDO,
  PED.KUNNR as ID_EXTERNO,
  CLI.NAME1 as CLIENTE,
  NF.COD_CTA_HEADER as CONTA_RAZAO,
  PED.ABSTK as STATUS_RECUSA,
  PED.NETWR as MONTANTE
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` as PED
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` as ITEM
  ON PED.MANDT = ITEM.MANDT AND PED.VBELN = ITEM.VBELN
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as CLI
  ON PED.MANDT = CLI.MANDT AND PED.KUNNR = CLI.KUNNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` as NF
  ON NF.PSTDAT = PED.AUDAT AND NF.PARID = PED.KUNNR AND NF.BUKRS = PED.VKORG AND NF.NFTOT = PED.NETWR
WHERE
  PED.MANDT = '300' AND
  PED.ERDAT BETWEEN '2025-01-01' AND '2025-04-30' AND
  PED.ABSTK = 'A'