WITH base_aberto AS (
  SELECT DISTINCT
    ABT.MANDT,
    ABT.BUKRS,
    ABT.BUPLA,
    CONCAT(LEFT(ABT.BUKRS, 2), RIGHT(ABT.BUPLA, 2)) AS Centro,
    ABT.KUNNR,
    ABT.DMBTR,
    ABT.H_BUDAT,
    ABT.NETDT,
    ABT.ZBD1T,
    ABT.SGTXT,
    ABT.H_BLART
  FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS ABT
  WHERE
    ABT.BUKRS IN ('2000', '2100', '2200', '2300', '2400', '2500', '2600', '2700', '2800', '2900', '3000', '3100', '3200', '3300') 
    AND ABT.KUNNR NOT IN ('1000016115', '1000300196', '1000002790', '5200000001') -- Retira operadoras de cartão
    AND ABT.H_BLART IN ('RV', 'ZP') -- RV: Doc. Faturamento | ZP: Lançamento pgto
    AND ABT.BUPLA <> '' -- Retirar o local de negócios vazios
    AND ABT.AUGBL = '' -- Doc. compensação vazio
    AND ABT.KOART = 'D' -- Apenas clientes
    AND ABT.NETDT <= DATE '2026-06-30' -- Data_base
--    AND ABT.KUNNR = '1000000452'
),

clientes AS (
  SELECT
    MANDT,
    KUNNR,
    ANY_VALUE(NAME1) AS Cliente
  FROM `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1`
  GROUP BY
    MANDT,
    KUNNR
),

aberto_por_cliente AS (
  SELECT
    B.BUKRS AS Empresa,
    B.BUPLA AS Local_Negocios,
    B.Centro,
    B.KUNNR AS ID_Externo,
    COALESCE(C.Cliente, 'SEM CADASTRO') AS Cliente,
    SUM(B.DMBTR) AS Montante_Cliente
  FROM base_aberto AS B
  LEFT JOIN clientes AS C
    ON B.MANDT = C.MANDT
   AND B.KUNNR = C.KUNNR
  GROUP BY
    B.BUKRS,
    B.BUPLA,
    B.Centro,
    B.KUNNR,
    Cliente
),

total_empresa AS (
  SELECT
    Empresa,
    SUM(Montante_Cliente) AS Total_Aberto_Empresa
  FROM aberto_por_cliente
  GROUP BY
    Empresa
),

total_centro AS (
  SELECT
    Empresa,
    Local_Negocios,
    Centro,
    SUM(Montante_Cliente) AS Total_Aberto_Centro
  FROM aberto_por_cliente
  GROUP BY
    Empresa,
    Local_Negocios,
    Centro
),

ranking_clientes AS (
  SELECT
    A.Empresa,
    A.Local_Negocios,
    A.Centro,
    A.ID_Externo,
    A.Cliente,
    A.Montante_Cliente,
    TE.Total_Aberto_Empresa,
    TC.Total_Aberto_Centro,
    ROW_NUMBER() OVER (
      PARTITION BY A.Empresa, A.Centro
      ORDER BY A.Montante_Cliente DESC, A.ID_Externo
    ) AS Ranking_Centro
  FROM aberto_por_cliente AS A
  INNER JOIN total_empresa AS TE
    ON A.Empresa = TE.Empresa
  INNER JOIN total_centro AS TC
    ON A.Empresa = TC.Empresa
   AND A.Local_Negocios = TC.Local_Negocios
   AND A.Centro = TC.Centro
)

SELECT
  Ranking_Centro,
  Empresa,
  Local_Negocios,
  Centro,
  ID_Externo,
  Cliente,
  Montante_Cliente,
  Total_Aberto_Centro,
  SAFE_DIVIDE(Montante_Cliente, Total_Aberto_Centro) AS Perc_Cliente_Sobre_Centro
FROM ranking_clientes
WHERE
  Ranking_Centro <= 10
ORDER BY
  Empresa,
  Centro,
  Ranking_Centro,
  ID_Externo;
