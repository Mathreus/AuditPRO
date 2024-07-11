SELECT
    PED.VKORG AS 'EMPRESA',
    ITEM.WERKS AS 'CENTRO',
    PED.ERDAT AS 'DATA_CRIACAO',
    PED.SPART AS 'SETOR_ATIVIDADE',
    PED.VBTYP AS 'CTG_DOCUMENTO',
    PED.AUART AS 'TIPO_DOC_VENDAS',
    PED.ABSTK AS 'STATUS',
    MAX(PED.VBELN) AS 'PEDIDO',
    PED.KUNNR AS 'ID_EXTERNO',
    CLI.NAME1 AS 'CLIENTE',
    PED.ERNAM AS 'USUARIO',
    PED.NETWR AS 'MONTANTE',
    RELV.PARTNER AS 'COD_ORIG_VEND', 
    VEND.BU_SORT2+' '+VEND.BU_SORT1 AS 'VENDEDOR'
FROM
    [SAPPS4300].[dbo].VBAK AS PED
INNER JOIN
    [SAPPS4300].[dbo].VBAP AS ITEM ON PED.MANDT = ITEM.MANDT AND PED.VBELN = ITEM.VBELN
INNER JOIN
	[SAPPS4300].[dbo].KNA1 AS CLI ON PED.MANDT = CLI.MANDT AND PED.KUNNR = CLI.KUNNR
INNER JOIN 
	[SAPPS4300].[dbo].BUT0ID AS RELV ON PED.MANDT = RELV.CLIENT AND RELV.IDNUMBER = ITEM.PERVE_ANA
INNER JOIN
	[SAPPS4300].[dbo].BUT000 AS VEND ON PED.MANDT = VEND.CLIENT AND RELV.PARTNER = VEND.PARTNER
WHERE
	PED.ERDAT BETWEEN '2024-01-01' AND '2024-06-30' AND
    PED.KUNNR > '1000000000' AND
    PED.VBTYP = 'C' AND
	PED.AUART IN ('OR1', 'ZCAS', 'ZPDV') AND
    PED.ABSTK = 'A'
GROUP BY
    PED.VKORG,
    ITEM.WERKS,
    PED.ERDAT,
    PED.KUNNR,
    CLI.NAME1,
    PED.SPART,
    PED.VBTYP,
    PED.AUART,
    PED.ABSTK,
    PED.ERNAM,
    PED.NETWR,
    RELV.PARTNER,
    VEND.BU_SORT2+' '+VEND.BU_SORT1