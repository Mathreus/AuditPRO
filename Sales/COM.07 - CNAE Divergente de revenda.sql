SELECT DISTINCT 
	CAD.KUNNR AS 'COD CLIENTE', 
	CAD.NAME1 AS 'NOME CLIENTE',
	CAD.STCD1 AS 'CNPJ', 
	CAD.CNAE, 
	CAD.KATR6 AS 'TIPO CONSUMIDOR', 
	DOC.PARTYP AS 'TIPO PESSOA'
FROM
	[SAPPS4300].[dbo].KNA1 AS CAD
INNER JOIN 
	[SAPPS4300].[dbo].J_1BNFDOC AS DOC ON CAD.NAME1 = DOC.NAME1
WHERE 
	CAD.KUNNR > '100000000' AND
	CAD.STCD1 <> '' AND
	CAD.CNAE NOT IN ('4530701', '4530702', '4530703', '4530704', '4530705', '4530706') AND 
	CAD.KATR6 = '02'  AND
	DOC.PARTYP = 'C'