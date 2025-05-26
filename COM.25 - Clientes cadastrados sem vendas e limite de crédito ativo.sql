SELECT
  b.kunnr as ID_Externo, 
  b.name1 as Nome,
  b.pstlz as CEP,
  b.stras as Rua,
  adrc.tel_number as Telefone,
  adr6.smtp_addr as Email,
  b.erdat as Dt_Criacao_Conta,
  c.VWERK as Centro,
  max(o.erdat) as Dt_Ultimo_Pedido,
  c.vkorg as Organizacao,
  c.vtweg as Canal,
  c.spart as Setor,
  knvp.pernr as ID_Vendedor,
  concat(BUT000.BU_SORT2,BUT000.BU_SORT1) as Vendedor,
  credit_limit as Limite_Credito
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` AS B
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvv` AS C 
  ON c.KUNNR = b.KUNNR
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.adrc` AS ADRC  
  ON b.adrnr = adrc.addrnumber 
  AND adrc.client='300'
LEFT JOIN
	`production-servers-magnumtires.prdmgm_sap_cdc_processed.adr6` AS ADR6 
  ON adrc.addrnumber = adr6.addrnumber
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvp` AS KNVP 
  ON b.kunnr = knvp.kunnr 
  AND knvp.parvw = 'VE' 
  AND knvp.mandt = '300'
LEFT JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS BUT0ID 
  ON knvp.pernr = but0id.idnumber 
  AND but0id.client = '300'
INNER JOIN   
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS BUT000 
  ON but000.partner = but0id.partner 
  AND but000.client = '300'
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.ukmbp_cms_sgm` AS ukmbp_cms_sgm 
  ON ukmbp_cms_sgm.partner = b.kunnr 
  AND ukmbp_cms_sgm.client = '300'
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS O 
  ON o.kunnr = b.kunnr 
  AND abstk = 'A'
WHERE
	b.erdat between '2025-01-01' and '2025-04-30'
group by 
  b.werks,
  b.kunnr,
  b.name1,
  b.pstlz,
  b.stras,
  b.kostl,
  adrc.tel_number,
  adr6.smtp_addr,
  b.erdat,
  c.vwerk,
  c.vkorg,
  c.vtweg,
  c.spart,
  knvp.pernr,
  concat(BUT000.BU_SORT2,BUT000.BU_SORT1),
  credit_limit