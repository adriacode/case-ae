import json

import requests
import pandas as pd

import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def extract_data(url:str) -> list:
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        data = response.json().get('data', []) 
        
        if not data: 
            logging.warning("Nenhum dado retornado")
            return []
        
        logging.info(f"Dados extraídos com sucesso !")
        return data
    
    except requests.exceptions.RequestException as e:
        logging.error(f"Erro na requisição: {e}")
        return []
    
    except Exception as e:
        logging.error(f"Erro inesperado: {e}")
        return []
