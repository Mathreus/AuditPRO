SELECT 
  CASE
    WHEN C.regio = 'AC' THEN 'Acre'
    WHEN C.regio = 'AP' THEN 'Amapá'
    WHEN C.regio = 'AM' THEN 'Amazonas'
    WHEN C.regio = 'PA' THEN 'Pará'
    WHEN C.regio = 'RO' THEN 'Rondônia'
    WHEN C.regio = 'RR' THEN 'Roraima'
    WHEN C.regio = 'TO' THEN 'Tocantins'
    WHEN C.regio = 'AL' THEN 'Alagoas'
    WHEN C.regio = 'BA' THEN 'Bahia'
    WHEN C.regio = 'CE' THEN 'Ceará'
    WHEN C.regio = 'MA' THEN 'Maranhão'
    WHEN C.regio = 'PB' THEN 'Paraíba'
    WHEN C.regio = 'PE' THEN 'Pernambuco'
    WHEN C.regio = 'PI' THEN 'Piauí'
    WHEN C.regio = 'RN' THEN 'Rio Grande do Norte'
    WHEN C.regio = 'SE' THEN 'Sergipe'
    WHEN C.regio = 'DF' THEN 'Brasília'
    WHEN C.regio = 'GO' THEN 'Goiás'
    WHEN C.regio = 'MT' THEN 'Mato Grosso'
    WHEN C.regio = 'MS' THEN 'Mato Grosso do Sul'
    WHEN C.regio = 'ES' THEN 'Espírito Santo'
    WHEN C.regio = 'MG' THEN 'Minas Gerais'
    WHEN C.regio = 'RJ' THEN 'Rio de Janeiro'
    WHEN C.regio = 'SP' THEN 'São Paulo'
    WHEN C.regio = 'PR' THEN 'Paraná'
    WHEN C.regio = 'RS' THEN 'Rio Grande do Sul'
    WHEN C.regio = 'SC' THEN 'Itajaí'
    ELSE 'N/D'
  END Estado,
  K.BUKRS AS Empresa,
  CONCAT(LEFT(K.BUKRS, 2), RIGHT(K.BUPLA, 2)) AS Centro,
  C.NAME1 AS Descricao_Centro,
  K.BUDAT AS DataLcto,
  EXTRACT(MONTH FROM K.BUDAT) AS Mes,
  EXTRACT(YEAR FROM K.BUDAT) AS Ano,
  FORMAT_DATE('%m-%y', K.BUDAT) AS Mes_Ano,
  CURRENT_DATE() AS DataHoje,
  K.BUDAT + CAST(K.ZBD1T AS INT64) AS DataVencimento,
  DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) AS Diferenca_Dias,
  K.LIFNR AS ID_Fornecedor,
  F.NAME1 AS Fornecedor,
  CASE
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 30 THEN '1 a 30' 
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 60 THEN '31 a 60'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 90 THEN '61 a 90'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 120 THEN '91 a 120'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 150 THEN '121 a 150'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 180 THEN '151 a 180'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 360 THEN '180 a 360'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 720 THEN '360 a 720 (1-2 anos)'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 1080 THEN '720 a 1080 (2-3 anos)'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 1440 THEN '1080 a 1440 (3-4 anos)'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 2160 THEN '1440 a 2160 (4-5 anos)'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 2520 THEN '2160 a 2520 (5-6 anos)'
    WHEN DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) <= 2880 THEN '2520 a 2880 (6-7 anos)'
    ELSE '2880 acima (7 anos acima)'
  END AS  AgingList, 
  CASE
    WHEN K.SHKZG = 'H' THEN 'Crédito'
    WHEN K.SHKZG = 'S' THEN 'Débito'
    ELSE 'Não identificado'
  END Debito_Credito,
  K.HKONT AS Conta_Contabil,
  K.BLART AS Tipo_Documento,
  K.ZTERM AS CondPGTO,
  K.DMBTR AS Montante
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bsik` as K
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as F 
  ON K.LIFNR = F.LIFNR
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.t001w` as C 
  ON CONCAT(LEFT(K.BUKRS, 2), RIGHT(K.BUPLA, 2)) = C.BWKEY
WHERE
  K.LIFNR > '1000000000' 
  AND F.LAND1 = 'BR'
  AND K.SHKZG = 'S' 
--  AND K.BLART = 'KZ'
  AND DATE_DIFF(CURRENT_DATE(), K.BUDAT + CAST(K.ZBD1T AS INT64), DAY) > 5