SELECT 
  -- Dados da Importadora (Saída)
  CONCAT(LEFT(imp.BUKRS, 2), RIGHT(imp.BRANCH, 2)) AS CENTRO_IMP,
  imp.PSTDAT AS DATA_LCTO_IMP,
  imp.CRETIM AS HORARIO_IMP,
  'Saída' AS MOVIMENTO_IMP,
  'Cliente' AS PARCEIRO_IMP,
  imp.PARID AS ID_EXTERNO_IMP,
  imp.NAME1 AS CLIENTE_IMP,
--  imp.CANCEL AS ESTORNADO_IMP,
--  imp.DOCTYP AS TIPO_DOC_IMP,
  imp.NFENUM AS NUM_NF_IMP,
  imp.CRENAM AS USUARIO_IMP,
  imp.NFTOT AS MONTANTE_IMP,
--  imp.NFTYPE AS TIPO_NF_IMP,
--  imp.NATOP AS REFERENCIA_IMP,
  
  -- Dados da Distribuidora (Entrada)
  CONCAT(LEFT(dist.BUKRS, 2), RIGHT(dist.BRANCH, 2)) AS CENTRO_DIST,
  dist.PSTDAT AS DATA_LCTO_DIST,
  dist.CRETIM AS HORARIO_DIST,
  'Entrada' AS MOVIMENTO_DIST,
  'Fornecedor' AS PARCEIRO_DIST,
  dist.PARID AS ID_EXTERNO_DIST,
  dist.NAME1 AS FORNECEDOR_DIST,
--  dist.CANCEL AS ESTORNADO_DIST,
  dist.CRENAM AS USUARIO_DIST,
  dist.NFENUM AS NUM_NF_DIST,
  dist.NFTOT AS MONTANTE_DIST,
--  dist.NATOP AS REFERENCIA_DIST,

  -- Campos de comparação
  CASE WHEN dist.NFENUM IS NOT NULL THEN 'OK' ELSE 'PENDENTE' END AS STATUS_RECEBIMENTO,
  imp.NFTOT - COALESCE(dist.NFTOT, 0) AS DIFERENCA_VALOR

FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS imp
LEFT JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS dist
  ON imp.NFENUM = dist.NFENUM
  AND imp.PSTDAT = dist.PSTDAT
  -- Adicione mais condições de relacionamento conforme necessário
  -- Exemplo: AND imp.SERIES = dist.SERIES

WHERE
  -- Filtros para notas de SAÍDA da Importadora
  imp.BUKRS = '1000'
  AND imp.PSTDAT BETWEEN '2025-01-01' AND '2025-01-31'
  AND imp.DIRECT = '2' -- Saída
  AND imp.PARTYP = 'C' -- Cliente
  AND imp.PARID BETWEEN '0000002001' AND '0000002999' -- Faixa de clientes importadora
  AND imp.doctyp = '1' -- Tipo de documento
  AND imp.CANCEL = '' -- Não cancelado
  AND (imp.NATOP LIKE '%Venda%' OR imp.NATOP LIKE '%Vnd%') -- Natureza operação

  -- Filtros para notas de ENTRADA nas Distribuidoras (aplicados apenas quando há match)
  AND (dist.BUKRS IS NULL OR (
    dist.BUKRS NOT IN ('1000')
    AND dist.DIRECT = '1' -- Entrada
    AND dist.PARTYP = 'V' -- Fornecedor
    AND dist.PARID BETWEEN '0000001001' AND '0000001999' -- Faixa de fornecedores distribuidora
    AND dist.CANCEL <> 'X' -- Não cancelado
  ))

ORDER BY
  imp.PSTDAT DESC,
  STATUS_RECEBIMENTO,
  imp.NFENUM
