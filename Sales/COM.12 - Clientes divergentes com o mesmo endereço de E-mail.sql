select distinct
  c.vkorg as Organizacao,
  c.vwerk as Centro,
  c.vtweg as Canal,
  c.spart as Setor,
  b.kunnr as ID_Externo,
  b.name1 as Nome,
  adrc.tel_number as Telefone,
  adr6.smtp_addr as Email,
  b.erdat as Dt_Criacao_Conta,
  max(o.erdat) as Dt_Ultimo_Pedido,
  knvp.pernr as ID_Vendedor,
  concat(but000.bu_sort2, but000.bu_sort1) as Vendedor,
  credit_limit as Limite_Credito
from
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1` as b
left join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvv` as c on c.kunnr = b.kunnr
left join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.adrc` as adrc on 
  b.adrnr = adrc.addrnumber and
  adrc.client='300'
left join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.adr6` as adr6 on
  adrc.addrnumber = adr6.addrnumber
left join
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.knvp` as knvp on
  b.kunnr = knvp.kunnr and
  knvp.parvw ='VE' and
  knvp.mandt = '300'
left join 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS but0id ON
  knvp.pernr = but0id.idnumber AND
  but0id.client = '300'
INNER JOIN   
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS but000 ON
  but000.partner = but0id.partner AND
  but000.client = '300'
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.ukmbp_cms_sgm` AS ukmbp_cms_sgm ON
  ukmbp_cms_sgm.partner = b.kunnr AND
  ukmbp_cms_sgm.client = '300'
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS o ON
  o.kunnr = b.kunnr AND
  abstk = 'A'
WHERE
  c.vwerk in ('2007', '2022') and
  b.erdat BETWEEN '2024-01-01' AND '2024-01-31' --and
--  credit_limit > 20000
GROUP BY 
  b.werks,
  b.kunnr,
  b.name1,
  b.kostl,
  adrc.tel_number,
  adr6.smtp_addr,
  b.erdat,
  c.vwerk,
  c.vkorg,
  c.vtweg,
  c.spart,
  knvp.pernr,
  but000.bu_sort1,
  but000.bu_sort2,
  CONCAT(but000.bu_sort2, but000.bu_sort1),
  credit_limit
HAVING 
  COUNT(adr6.smtp_addr) > 1