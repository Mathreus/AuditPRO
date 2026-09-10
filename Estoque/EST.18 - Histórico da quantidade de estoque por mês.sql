WITH MBEW as (  
  SELECT bwkey , matnr, lfgja, lfmon, avg(verpr) as verpr from (
    SELECT DISTINCT * FROM (
      SELECT 
        h.bwkey,
        h.matnr, 
        h.lfgja, 
        h.lfmon,
        h.verpr
      FROM 
        `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbvmbewh` AS h
      WHERE 
        ltrim(h.bwtar) = ''
UNION ALL 
  SELECT 
    h.bwkey,
    h.matnr,
    h.lfgja,
    h.lfmon,
    h.verpr
  FROM 
    `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` AS h
  WHERE
    ltrim(h.bwtar) = '' 
) a
) b
--where ltrim(matnr,'0') = '100028' and lfgja = '2023' and bwkey = '1002'
GROUP BY
  bwkey , matnr, lfgja, lfmon
ORDER BY 4
)

SELECT 

  d.werks as Centro, 
  d.lgort as Armazem, 
  d.lfgja as Ano, 
  CASE
    WHEN d.lfmon = '01' THEN 'Janeiro'
    WHEN d.lfmon = '02' THEN 'Fevereiro'
    WHEN d.lfmon = '03' THEN 'Março'
    WHEN d.lfmon = '04' THEN 'Abril'
    WHEN d.lfmon = '05' THEN 'Maio'
    WHEN d.lfmon = '06' THEN 'Junho'
    WHEN d.lfmon = '07' THEN 'Julho'
    WHEN d.lfmon = '08' THEN 'Agosto'
    WHEN d.lfmon = '09' THEN 'Setembro'
    WHEN d.lfmon = '10' THEN 'Outubro'
    WHEN d.lfmon = '11' THEN 'Novembro'
    WHEN d.lfmon = '12' THEN 'Dezembro'
    ELSE 'Nada'
  END Mes,
  mara.MaterialGroup_MATKL as Grupo, 
  mara.Marca, 
  mara.Medida_Ampliada, 
  mara.Origem, 
  mara.GRUPO as SuperGrupo,
  LTRIM(d.matnr,'0') AS Produto, 
  mara.MaterialText_MAKTX as Descricao, 
  d.labst+d.speme as Estoque, 
--m.verpr,
  CASE 
    WHEN d.labst+d.speme > 0 and (m.verpr = 0 or m.verpr is null) THEN 
    (Select avg(mb.verpr) from `production-servers-magnumtires.prdmgm_sap_cdc_processed.mbew` mb where mb.bwkey = d.werks and d.matnr = mb.matnr 
and ltrim(mb.bwtar) = '' -- ltrim(mb.bwtar) >= (Case When left(mb.bwkey,1) in ('1','6') then 'a' ELSE '' END)
--and ltrim(matnr,'0') = '100028' and lfgja = '2023' and bwkey = '1002' --and d.lfmon = '12'
) 
    ELSE m.verpr 
  END Custo
FROM 
  `production-servers-magnumtires.prdmgm_sap_cdc_processed.nsdm_v_mardh` AS d
INNER JOIN 
  `production-servers-magnumtires.prdmgm_sap_reporting.MaterialsMD` mara ON
  mara.MaterialNumber_MATNR = d.matnr 
  AND mara.MaterialType_MTART = 'HAWA'
LEFT JOIN 
  MBEW m ON
  m.bwkey = d.werks 
  AND m.matnr = d.matnr 
  AND m.lfgja = d.lfgja 
  AND m.lfmon = d.lfmon 
WHERE
  d.lgort = 'DREV'
  AND d.lfgja = '2024'
  AND d.werks = '2007'
  AND ltrim(d.matnr,'0') = '101062'
--AND left(d.werks,1) in ('1','6')
--and d.werks = '3101' and d.lfgja = '2023' and d.lfmon = '12'
--where ltrim(d.matnr,'0') = '100028' and d.lfgja = '2023' and d.werks = '1002' and d.lfmon = '12'
ORDER BY
  d.werks, d.matnr, d.lgort, d.lfgja, d.lfmon