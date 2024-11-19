SELECT DISTINCT
  B.BUKRS AS Empresa,
  B.GJAHR AS Ano,
  B.AUGDT AS Data_Compensacao,
  B.AUGBL AS Documento_Compensacao,
  B.KUNNR AS ID_Externo,
  CLI.NAME1 AS Cliente,
  B.DMBTR AS ValorCompensado,
  B.ZUONR AS Atribuicao,
  B.SGTXT AS Texto,
  B.HBKID AS Banco
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS B
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI ON
  B.KUNNR = CLI.KUNNR 
WHERE
  B.KUNNR > '1000000000'
  AND B.GJAHR = '2024'
  AND B.AUGDT IS NOT NULL
  AND B.BSCHL = '11'       
  AND B.H_BLART = 'DG'      
  AND B.SHKZG = 'H'
  AND B.AUGBL = '1400003218'
--  AND B.HBKID <> ''
--  AND (B.HBKID IS NULL OR B.HBKID = '') 
ORDER BY
  B.AUGDT
-- B.AUGBL = '5120000381'
-- AND B.HKONT LIKE '%10101023%'