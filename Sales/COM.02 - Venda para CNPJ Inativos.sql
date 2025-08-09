import requests
import pandas as pd
import time

# Carrega os dados garantindo que CNPJ seja lido como texto
df1 = pd.read_excel(
    r'C:\Users\mathe\OneDrive\Documentos\Scripts\Bases/Clientes.xlsx',
    dtype={'CNPJ': str}  # Força a coluna CNPJ a ser interpretada como texto
)

# Remove possíveis caracteres não numéricos e preenche com zeros à esquerda
df1['CNPJ'] = df1['CNPJ'].astype(str).str.replace(r'\D', '', regex=True).str.zfill(14)
cnpjs = df1['CNPJ']

# DataFrame para armazenar os resultados
resultados = pd.DataFrame(columns=['CNPJ', 'SITUACAO'])

def consulta_cnpj(cnpj):
    # Garante que o CNPJ tenha 14 dígitos
    cnpj_formatado = str(cnpj).zfill(14)
    url = f'https://www.receitaws.com.br/v1/cnpj/{cnpj_formatado}'
    params = {
        "token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "plugin": "RF"
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()  # Verifica erros HTTP
        dados = response.json()
        
        # Pausa para respeitar o limite da API
        time.sleep(30)
        
        return dados.get('situacao', 'NÃO ENCONTRADO')
    
    except Exception as e:
        print(f"Erro ao consultar {cnpj_formatado}: {str(e)}")
        return "ERRO NA CONSULTA"

# Processa cada CNPJ
for cnpj in cnpjs:
    situacao = consulta_cnpj(cnpj)
    
    # Exibe no console (com CNPJ formatado)
    cnpj_formatado = f"{cnpj[:2]}.{cnpj[2:5]}.{cnpj[5:8]}/{cnpj[8:12]}-{cnpj[12:14]}"
    print(f"{cnpj_formatado} | {situacao}")
    
    # Adiciona ao DataFrame de resultados
    resultados.loc[len(resultados)] = [cnpj_formatado, situacao]

# Opcional: Salva os resultados em um novo arquivo Excel
resultados.to_excel('Resultados_Situacao_CNPJ.xlsx', index=False)
