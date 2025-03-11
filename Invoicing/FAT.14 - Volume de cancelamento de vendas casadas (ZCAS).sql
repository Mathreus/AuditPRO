SELECT DISTINCT
	CONCAT(left(nf.bukrs, 2), right(nf.branch, 2)) as Centro,
	NF.PSTDAT as Dt_lan,
  CASE
    WHEN ped.spart = '01' THEN 'Consumo'
    WHEN ped.spart = '02' THEN 'Revenda'
    ELSE 'Não Identificado'
  END Canal,
  NF.PARID as ID_Externo,
	NF.NAME1 as Cliente,
	PED.VBELN as Pedido,
  CASE
    WHEN PED.ABSTK = 'A' THEN 'Pedido Aprovado'
    WHEN PED.ABSTK = 'B' THEN 'Pedido aprovado parcialmente'
    WHEN PED.ABSTK = 'C' THEN 'Pedido Cancelado'
  END Aprovacao_Pedido,
	NF.NFENUM as Num_nfe,
  NF.CANCEL as Estorno,
  NF.CRETIM AS Horario,
  NF.CHATIM AS Hora_Modif,
  NF.CRENAM as Usuario,  
	NF.NFTOT as Faturamento,
  NF.NATOP AS Referencia,
  PED.VKBUR as Equipe_Vendas,
	RELV.PARTNER as Cod_orig_vend, 
	CONCAT(VEND.BU_SORT2,' ',VEND.BU_SORT1) as Vendedor
FROM
  production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak as ped
INNER JOIN 
  production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap as item on
  ped.mandt = item.mandt and
  ped.vbeln = item.vbeln
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin as lin on
  lin.xped = item.vbeln and
  lin.matnr = item.matnr and
  lin.itmnum = item.posnr 
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc as nf on
  lin.mandt = nf.mandt and
  lin.docnum = nf.docnum
INNER JOIN
  production-servers-magnumtires.prdmgm_sap_cdc_processed.kna1 as cli on
  ped.mandt = cli.mandt and
  ped.kunnr = cli.kunnr
INNER JOIN 
	production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id as relv on
	ped.mandt = relv.client and
	relv.idnumber = item.perve_ana
INNER JOIN
	production-servers-magnumtires.prdmgm_sap_cdc_processed.but000 as vend on
	ped.mandt = vend.client and
	relv.partner = vend.partner
WHERE
  NF.PSTDAT BETWEEN '2024-01-01' AND '2024-12-31' 
  AND PED.AUART = 'ZCAS'
  AND NF.DIRECT = '2' 
  AND NF.PARID > '1000000000' 
  AND PED.ABSTK IN ('A', 'C') 
  AND NF.CANCEL = 'X' 