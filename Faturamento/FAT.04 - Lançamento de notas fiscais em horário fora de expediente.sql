Select distinct 
  nf.bukrs as Empresa, 
  concat(left(nf.bukrs, 2), right(nf.branch, 2)) AS Centro,
  nf.docdat as Data_Documento, 
  nf.cretim as Horario,
  nf.crenam as Usuario,
  nf.direct as Direcao,
  nf.partyp as Tipo_pessoa,
  nf.parid as ID_Externo,
  nf.name1 as Cliente, 
  nf.nfenum as Num_nf, 
  nf.nftot as Valor_NF 
from 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf
where 
  nf.mandt = '300' and 
  nf.docdat between '2024-01-01' and '2024-06-31' and 
  nf.crenam not in ('JOB_USER', 'INTEGRACAO') and
  nf.cretim between time '21:00:00' and time '23:59:59' and
  nf.partyp = 'C' and
  nf.parid > '1000000000'