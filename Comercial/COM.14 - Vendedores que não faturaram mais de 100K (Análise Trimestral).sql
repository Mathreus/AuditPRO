WITH Vendas AS (
  SELECT
    CASE FORMAT_DATE('%m', nf.pstdat)
      WHEN '04' THEN 'Abril'
      WHEN '05' THEN 'Maio'
      WHEN '06' THEN 'Junho'
      ELSE 'Outro'
    END as MesVenda, 
    nf.pstdat as DataVenda,
    vend.crdat AS DataCadastro,
    CAST('2024-04-30' AS DATE) AS DataLimite,
    DATE_DIFF(CAST('2024-04-30' AS DATE), CAST(vend.crdat AS DATE), DAY) AS DiasTrabalhados,
    relv.partner AS cod_orig_vend,
    CONCAT(vend.bu_sort2, ' ', vend.bu_sort1) AS Vendedor,
    nf.nftot AS Faturamento
  FROM
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS ped
  INNER JOIN  
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS item ON
    ped.mandt = item.mandt AND
    ped.vbeln = item.vbeln
  INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbfa` AS fa ON
    ped.mandt = fa.mandt AND 
    ped.vbeln = fa.vbelv AND
    fa.vbtyp_n = 'M'
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrk` AS fat ON
    fat.mandt = ped.mandt AND
    fa.vbeln = fat.vbeln
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbrp` AS rp ON
    rp.mandt = ped.mandt AND
    fat.vbeln = rp.vbeln
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
    lin.mandt = ped.mandt AND
    rp.vbeln = lin.refkey AND
    rp.matnr = lin.matnr
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf ON
    nf.mandt = ped.mandt AND
    lin.docnum = nf.docnum
  INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS relv ON
    ped.mandt = relv.client AND
    relv.idnumber = item.perve_ana
  INNER JOIN
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS vend ON
    ped.mandt = vend.client AND
    relv.partner = vend.partner
  WHERE
   CAST(vend.crdat AS DATE) <= CAST('2024-03-31' AS DATE) AND
    nf.pstdat BETWEEN '2024-04-01' AND '2024-06-30' AND
    DATE_DIFF(CAST('2024-04-30' AS DATE), CAST(vend.crdat AS DATE), DAY) > 90 AND
    ped.abstk = 'A' AND
    nf.parid > '1000000000' AND
    nf.direct = '2' AND
    nf.nfenum IS NOT NULL AND
    relv.partner = '9980000682'
)

SELECT
  DataCadastro,
  DataLimite,
  DiasTrabalhados,
  cod_orig_vend,
  Vendedor,
  SUM(CASE WHEN MesVenda = 'Abril' THEN Faturamento ELSE 0 END) AS Faturamento_Abril,
  SUM(CASE WHEN MesVenda = 'Maio' THEN Faturamento ELSE 0 END) AS Faturamento_Maio,
  SUM(CASE WHEN MesVenda = 'Junho' THEN Faturamento ELSE 0 END) AS Faturamento_Junho,
  ROUND((SUM(CASE WHEN MesVenda = 'Abril' THEN Faturamento ELSE 0 END) +
         SUM(CASE WHEN MesVenda = 'Maio' THEN Faturamento ELSE 0 END) +
         SUM(CASE WHEN MesVenda = 'Junho' THEN Faturamento ELSE 0 END)) / 3, 2) AS Media
FROM
  Vendas
GROUP BY
  DataCadastro,
  DataLimite,
  DiasTrabalhados,
  cod_orig_vend,
  Vendedor
HAVING
  SUM(Faturamento) < 100000
ORDER BY
  Faturamento_Abril,
  Faturamento_Maio,
  Faturamento_Junho