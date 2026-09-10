SELECT DISTINCT
  CONCAT(LEFT(nf.bukrs, 2), RIGHT(nf.branch, 2)) AS Centro,
  NF.PARID AS ID_Externo,
  NF.NAME1 AS Cliente,
--  PED.ERDAT AS DataPedido,
  NF.PSTDAT AS DataNF,
--  PED.VBELN AS Pedido,
--  REM.VBELN AS Remessa,
  CASE
    WHEN NF.DIRECT = '1' THEN 'Entrada'
    WHEN NF.DIRECT = '2' THEN 'Saída'
    ELSE 'Nada'
  END DirecaoNF,
  NF.NFENUM AS Num_nfe, 
  NF.cancel AS Cancelamento,
  NF.CRENAM AS Usuario,
  RIGHT(LIN.MATNR, 6) AS Codigo_Material,
  LIN.MAKTX AS Texto_Breve_Material,
  LIN.CFOP AS CFOP,
  LIN.MENGE AS Quantidade,
  LIN.NETWR AS Montante,
--  PED.NETWR AS ValorPedido,
--  NF.NFTOT AS Faturamento,
  NF.NATOP AS Referencia,
--  PED.VKBUR AS Equipe_Vendas,
  LIN.refkey AS Doc_Orig,
  LIN.docnum AS Doc_Num_Lin,
--  RELV.PARTNER AS Cod_orig_vend, 
--  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor,

FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS nf
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS lin ON
  lin.docnum = nf.docnum
WHERE 
  nf.pstdat BETWEEN '2023-11-01' AND '2024-11-28' 
  AND LIN.CFOP NOT LIKE '%AB%'
  AND nf.parid IN ('1000120770', '1000085876', '1000059152', '1000159084', '1000163133', '1000163210', '1000163607', '1000144146', '1000170951')