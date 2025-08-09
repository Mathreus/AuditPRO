import requests
import json
import pandas as pd
import time

df1 = pd.read_excel(r'caminho\arquivo.xlsx')
df2 = df1['CNPJ']
df3 = (pd.DataFrame({'CNPJ': [], 'SITUACAO': []}))

def consulta_cnpj(cnpj):
    url = f'https://www.receitaws.com.br/v1/cnpj/{cnpj}'
    querystring = {"token": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "cnpj": "06990590000123", "plugin": "RF"}
    response = requests.request('GET', url, params=querystring)

    resp = json.loads(response.text)
    time.sleep(30)

    # Me retorna apenas os campos de meu interesse
    return resp['situacao']

# print((df1['CNPJ'].iloc[0]))

for i in range(len(df2)):
    # print(df1['CNPJ'].iloc[i])
    try:
        print(df1['CNPJ'].iloc[i], "|", consulta_cnpj(df1['CNPJ'].iloc[i]))

    except KeyError:
        print(df1['CNPJ'].iloc[i])
