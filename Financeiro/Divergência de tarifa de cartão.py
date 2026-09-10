from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.support.select import Select
from selenium.webdriver.support.ui import WebDriverWait             
from selenium.webdriver.support import expected_conditions as EC
import time
from selenium.webdriver.common.keys import Keys 
import os
import pandas as pd
import numpy as np
import re
from datetime import datetime

lista_arquivo = os.listdir("C:\\Users\jsoares\Downloads")

for arquivo in lista_arquivo:
    if 'csv' in arquivo:
        if "VisaoOperacionalDetalhe" in arquivo:
            os.rename(f'C:\\Users\jsoares\Downloads\{arquivo}', f'C:\\Users\jsoares\Tx.csv')

bd_tx_dia = pd.read_csv("Tx.csv", sep = ';' , engine = 'python')

tx_consolidado =  pd.read_csv("teste_tx_consolidado2.csv", sep = ';' ,engine = 'python')

tx_consolidado_novo = pd.concat([tx_consolidado, bd_tx_dia])

tx_consolidado_novo.to_csv("teste_tx_consolidado2.csv", sep = ';')

#excluir tabela tx após a consolidação
os.remove('Tx.csv')

consolidado =  tx_consolidado_novo

consolidado['Venda'] = consolidado['Venda'].astype(str).str.replace('.', '', regex=True)
consolidado['Tx. Admin.'] = consolidado['Tx. Admin.'].astype(str).str.replace('.', '', regex=True)

consolidado['Venda'] = consolidado['Venda'].astype(str).str.replace(',', '.')
consolidado['Tx. Admin.'] = consolidado['Tx. Admin.'].astype(str).str.replace(',', '.', regex=True)

consolidado['Venda'] = consolidado['Venda'].astype(str).str.replace('R', '', regex=True)
consolidado['Tx. Admin.'] = consolidado['Tx. Admin.'].astype(str).str.replace('R', '', regex=True)

consolidado['Venda'] = consolidado['Venda'].astype(str).str.replace('$', '', regex=True)
consolidado['Tx. Admin.'] = consolidado['Tx. Admin.'].astype(str).str.replace('$', '', regex=True)

consolidado['Venda'] = consolidado['Venda'].astype(str).str.replace(' ', '', regex=True)
consolidado['Tx. Admin.'] = consolidado['Tx. Admin.'].astype(str).str.replace(' ', '', regex=True)

# getnet mastercard 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0199 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0199 ),2)
consolidado1 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1 ) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado = consolidado[consolidado1]

#getnet mastercard 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0224 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0224 ),2)
consolidado2 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado2 = consolidado[consolidado2]

resultado = pd.concat([resultado, resultado2])

#getnet mastercard 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0247 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0247 ),2)
consolidado3 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado3 = consolidado[consolidado3]

resultado = pd.concat([resultado, resultado3])

#getnet visa 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0199 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0199 ),2)
consolidado4 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado4 = consolidado[consolidado4]

resultado = pd.concat([resultado, resultado4])

#getnet visa 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0224 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0224 ),2)
consolidado5 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado5 = consolidado[consolidado5]

resultado = pd.concat([resultado, resultado5])

#getnet visa 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0247 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0247 ),2)
consolidado6 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado6 = consolidado[consolidado6]

resultado = pd.concat([resultado, resultado6])

#getnet hiper 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0199 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0199 ),2)
consolidado7 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado7 = consolidado[consolidado7]

resultado = pd.concat([resultado, resultado7])

#getnet hiper 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0224 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0224 ),2)
consolidado8 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado8 = consolidado[consolidado8]

resultado = pd.concat([resultado, resultado8])

#getnet hiper 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0247 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0247 ),2)
consolidado9 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado9 = consolidado[consolidado9]

resultado = pd.concat([resultado, resultado9])

#getnet amex 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0199 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0199 ),2)
consolidado10 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'AMEX')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado10 = consolidado[consolidado10]

resultado = pd.concat([resultado, resultado10])

#getnet amex 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0224 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0224 ),2)
consolidado11 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'AMEX')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado11 = consolidado[consolidado11]

resultado = pd.concat([resultado, resultado11])

#getnet amex 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0247 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0247 ),2)
consolidado12 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'AMEX')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado12 = consolidado[consolidado12]

resultado = pd.concat([resultado, resultado12])

#getnet ELO CREDITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0199 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0199 ),2)
consolidado13 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado13 = consolidado[consolidado13]

resultado = pd.concat([resultado, resultado13])

#getnet ELO CREDITO 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0224 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0224 ),2)
consolidado14 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado14 = consolidado[consolidado14]

resultado = pd.concat([resultado, resultado14])

#getnet ELO CREDITO 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0247 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0247 ),2)
consolidado15 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado15 = consolidado[consolidado15]

resultado = pd.concat([resultado, resultado15])

#getnet ELO DEBITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0105 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0105 ),2)
consolidado16 = (consolidado['Operadora'] == 'GETNET') & (consolidado['Produto'] == 'ELO DEBITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado16 = consolidado[consolidado16]

resultado = pd.concat([resultado, resultado16])

#SAFRAPAY ELO CREDITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0185 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0185 ),2)
consolidado19 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado19 = consolidado[consolidado19]

resultado = pd.concat([resultado, resultado19])

#SAFRAPAY ELO CREDITO 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0212 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0212 ),2)
consolidado20 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado20 = consolidado[consolidado20]

resultado = pd.concat([resultado, resultado20])

#SAFRAPAY ELO CREDITO 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0238 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0238 ),2)
consolidado21 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'ELO CREDITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado21 = consolidado[consolidado21]

resultado = pd.concat([resultado, resultado21])

#SAFRAPAY HIPER CREDITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0250 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0250 ),2)
consolidado25 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado25 = consolidado[consolidado25]

resultado = pd.concat([resultado, resultado25])

#SAFRAPAY HIPER CREDITO 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0270 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0270 ),2)
consolidado26 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado26 = consolidado[consolidado26]

resultado = pd.concat([resultado, resultado26])

#SAFRAPAY HIPER CREDITO 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0299 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0299 ),2)
consolidado27 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'HIPERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado27 = consolidado[consolidado27]

resultado = pd.concat([resultado, resultado27])

#SAFRAPAY MASTERCARD 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0180 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0180 ),2)
consolidado28 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado28 = consolidado[consolidado28]

resultado = pd.concat([resultado, resultado28])

#SAFRAPAY MASTERCARD 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0217 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0217 ),2)
consolidado29 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado29 = consolidado[consolidado29]

resultado = pd.concat([resultado, resultado29])

#SAFRAPAY MASTERCARD 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0235 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0235 ),2)
consolidado30 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'MASTERCARD')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado30 = consolidado[consolidado30]

resultado = pd.concat([resultado, resultado30])

#SAFRAPAY VISA 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0180 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0180 ),2)
consolidado31 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado31 = consolidado[consolidado31]

resultado = pd.concat([resultado, resultado31])

#SAFRAPAY VISA 2 a 6 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0205 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0205 ),2)
consolidado32 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & ((consolidado['Plano'] >= 2) & (consolidado['Plano'] <= 6)) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado32 = consolidado[consolidado32]

resultado = pd.concat([resultado, resultado32])

#SAFRAPAY VISA 7 a 12 parcelas

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0228 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0228 ),2)
consolidado33 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'VISA')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] > 6) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado33 = consolidado[consolidado33]

resultado = pd.concat([resultado, resultado33])

#SAFRAPAY ELO DEBITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0089 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0089 ),2)
consolidado34 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'ELO DEBITO')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado34 = consolidado[consolidado34]

resultado = pd.concat([resultado, resultado34])

#SAFRAPAY VISA DEBITO 1 parcela

consolidado['TAR_COBRADA'] = round((((consolidado['Tx. Admin.']).astype(float) / consolidado['Venda'].astype(float)) * 100.00),2)
consolidado['TAR_AUDITORIA'] = round((0.0086 * 100),2)
consolidado['DIF_TARIFA'] = round((consolidado['TAR_COBRADA'] - consolidado['TAR_AUDITORIA'] ),2)
consolidado['DIF_VLR_AUD'] = round((consolidado['Tx. Admin.']).astype(float) - (((consolidado['Venda']).astype(float)) * 0.0086 ),2)
consolidado35 = (consolidado['Operadora'] == 'SAFRAPAY') & (consolidado['Produto'] == 'VISA ELECTRON')  & (consolidado['Status'] == 'LIQUIDADO') & (consolidado['Plano'] == 1) & (consolidado['DIF_VLR_AUD'] > 1.00 ) & (consolidado['DIF_TARIFA'] > 0.01 )
resultado35 = consolidado[consolidado35]

resultado = pd.concat([resultado, resultado35])

data = datetime.today()
hoje = data.strftime('%d_%m_%Y')
nome = 'FIN40_DivergenciaTarifaCartao'
extensao = '.xlsx'

#tx_consolidado_novo = pd.concat([tx_consolidado, bd_tx_dia])
resultado.to_excel(f'{nome}_{hoje}{extensao}', index = True)