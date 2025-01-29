SELECT DISTINCT 
    B.BUKRS as Centro,
    B.LIFNR as ID_Fornecedor, 
    F.NAME1 as Fornecedor, 
    B.BELNR as Lcto_ctb,
    B.H_BUDAT as DT_Lancamento,
    FORMAT_DATE('%d/%m/%Y', DATE_ADD(B.ZFBDT, INTERVAL CAST(B.ZBD1T AS INT64) DAY)) AS Data_Vencimento,
    FORMAT_DATE('%d/%m/%Y', CURRENT_DATE()) AS Data_Hoje,
    B.AUGCP as Data_Compensacao,   
    CASE
        WHEN B.SHKZG = 'S' THEN 'Débito'
        WHEN B.SHKZG = 'H' THEN 'Crédito'
        ELSE 'Não identificado'
    END Debito_Credito, 
    B.DMBTR as Montante,
    B.SGTXT as Texto
FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as B
INNER JOIN 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.lfa1` as F ON
    B.MANDT = F.MANDT 
    AND B.LIFNR = F.LIFNR
WHERE 
  B.LIFNR > '1000000000'  
  AND DATE_DIFF(CURRENT_DATE(), B.H_BUDAT, DAY) > 30 
  AND B.AUGBL = ''  
  AND B.HKONT = '1010301001'
