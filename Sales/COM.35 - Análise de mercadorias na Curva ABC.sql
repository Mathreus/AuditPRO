SELECT DISTINCT
  `Empresa`,
  `Centro`,
  `Super_Grupo`,
  `Familia`,
  `Medida Ampliada`,
  `MARCA`,
  `ORIGEM`,
  `Material`,
  `DescricaoProduto_MAKTG`,
  `Soma de Qtde Vendido`,
  `Soma de Valor Pedidos Aprovados`,
  `% individual_valor`,
  `% acumulado_valor`,
  `ABC Valor`,
  Concat(`ABC Valor`,`ABC Pedido`) as `ABC Valor + Pedido`,
  Case When `ABC Valor` = 'A' Then 'Normal'
    When `ABC Pedido`= 'A' Then 'Normal'
    When Concat(`ABC Valor`,`ABC Pedido`) = 'BB' Then 'Normal'
    Else 'Casada' end ` Tipo de Venda`, ''  as ` Curva C Importantes`,    
  round(`Preço Médio`, 2),  
  round(`Custo Medio`, 2)
FROM 
  `production-servers-magnumtires.prdmgm_views.Politica_Distribuicao_S_OP`
WHERE
  Centro = '2015'