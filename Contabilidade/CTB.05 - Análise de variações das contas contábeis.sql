select
  b.bukrs as Empresa,
  left(b.kostl, 4) as Centro,
  b.gjahr as Exercicio,
  b.h_budat as Data_Lcto,
  b.shkzg as D_C,
  b.hkont as Conta_Contabil,
  b.sgtxt as Texto,
  sum(b.wrbtr) as Montante
from
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.bseg` as b
where
  b.mandt = '300' and
--  b.bukrs = '2700' and
  b.gjahr = '2023' and
  b.h_budat between '2023-01-01' and '2023-12-31' and
  b.shkzg = 'S' and
--  b.hkont = '3030404009'
group by
  b.bukrs,
  b.kostl,
  b.gjahr,
  b.h_budat,
  b.shkzg,
  b.hkont,
  b.sgtxt,
  b.wrbtr
order by
  b.hkont