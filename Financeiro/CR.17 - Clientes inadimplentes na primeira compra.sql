SELECT 
  CLI.kunnr as ID_Externo,
  CLI.name1 as Cliente,
  CLI.erdat as dt_cadastro,
  min(FIN.h_budat) as dt_base,
  sum(FIN.dmbtr) as Montante
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS CLI
LEFT OUTER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` AS FIN ON
  CLI.kunnr = FIN.kunnr
WHERE
  CLI.erdat between '2024-01-01' AND '2024-11-18' 
  AND FIN.zlsch = 'E' 
  AND DATE_DIFF(CURRENT_DATE() ,FIN.netdt, DAY) > 0 
  AND FIN.augdt is null AND FIN.h_blart = 'RV'
GROUP BY 
  CLI.kunnr, CLI.name1, CLI.erdat