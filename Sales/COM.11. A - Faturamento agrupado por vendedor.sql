SELECT DISTINCT
  RELV.PARTNER AS Cod_orig_vend, 
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1) AS Vendedor,

-- Faturamento Janeiro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 1 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Janeiro,

-- Devoluções Janeiro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 1 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Janeiro,

-- Faturamento Fevereiro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 2 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Fevereiro,

-- Devolucoes Fevereiro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 2 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Fevereiro,

-- Faturamento Março
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 3 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Marco,

-- Devoluções Março
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 3 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Marco,

-- Faturamento Abril
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 4 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Abril,

-- Devoluções Abril
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 4 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Abril,

-- Faturamento Maio
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 5 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Maio,

-- Devoluções Maio
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 5 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Maio,

-- Faturamento Junho
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 6 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Junho,

-- Devoluções Junho
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 6 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Junho,

  -- Faturamento Julho
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 7 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Julho,

-- Devoluções Julho
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 7 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Julho,


  -- Faturamento Agosto
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 8 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Agosto,

-- Devoluções Agosto
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 8 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devolucoes_Agosto,

  -- Faturamento Setembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 9 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Setembro,

-- Devoluções Setembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 9 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devoluoes_Setembro,

-- Faturamento Outubro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 10 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Outubro,

-- Devoluções Outubro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 10 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devoluoes_Outubro,

-- Faturamento Novembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 11 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Novembro,

-- Devoluções Novembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 11 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devoluoes_Novembro,

  -- Faturamento Novembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 12 AND NF.NFTYPE = 'YC' THEN LIN.NETWR
      ELSE 0 
  END) AS Faturamento_Dezembro,

-- Devoluções Novembro
  SUM(CASE 
      WHEN EXTRACT(MONTH FROM NF.PSTDAT) = 12 AND NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0 
  END) AS Devoluoes_Dezembro,

  -- Totais de faturamento e devoluções
  SUM(CASE WHEN NF.NFTYPE = 'YC' THEN LIN.NETWR ELSE 0 END) AS Total_Vendas,
  SUM(CASE WHEN NF.NFTYPE IN ('ZD', 'ZE', 'ZP', 'YH') THEN LIN.NETWR * -1 ELSE 0 END) AS Total_Devolucoes,

  -- Liquido (Vendas - Devoluções)
  SUM(
    CASE 
      WHEN NF.NFTYPE = 'YC' THEN LIN.NETWR
      WHEN NF.NFTYPE IN ('ZD', 'ZE', 'ZP') THEN LIN.NETWR * -1
      ELSE 0
    END
  ) AS Faturamento_Liquido
FROM
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbak` AS PED
INNER JOIN  
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.vbap` AS ITEM 
  ON ped.mandt = item.mandt 
  AND ped.vbeln = item.vbeln
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnflin` AS LIN 
  ON lin.xped = item.vbeln 
  AND lin.matnr = item.matnr 
  AND lin.itmnum = item.posnr 
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.j_1bnfdoc` AS NF 
  ON lin.mandt = nf.mandt 
  AND lin.docnum = nf.docnum
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but0id` AS RELV 
  ON ped.mandt = relv.client 
  AND relv.idnumber = item.perve_ana
INNER JOIN
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.but000` AS VEND 
  ON ped.mandt = vend.client 
  AND relv.partner = vend.partner
WHERE 
  nf.pstdat between '2025-01-01' AND '2025-05-31' 
  AND nf.parid > '1000000000' 
  AND nf.nfenum <> 'NULL' 
  AND nf.cancel <> 'X'   
  AND ped.abstk = 'A'
  AND nf.direct IN ('1', '2')
  AND NF.NFTYPE IN ('YC', 'ZD', 'ZE', 'ZP')
GROUP BY
  RELV.PARTNER,
  CONCAT(VEND.BU_SORT2, ' ', VEND.BU_SORT1)
ORDER BY
  RELV.PARTNER ASC
