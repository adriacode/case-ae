import requests
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def extract_data(url):
    """
    Extrai dados de uma API externa.

    Parâmetros:
        url (str): Endpoint da API.

    Retorno:
        list: Lista de registros extraídos. Retorna lista vazia em caso de erro.
    """

    try:
        logging.info(f"Iniciando extração de dados da API: {url}")

        response = requests.get(url, timeout=10)
        response.raise_for_status()

        response_json = response.json()

        # Trata diferentes formatos de resposta da API
        if isinstance(response_json, list):
            data = response_json
        else:
            data = response_json.get("data", [])

        if not data:
            logging.warning("Nenhum dado retornado pela API")
            return []

        logging.info(f"{len(data)} registros extraídos com sucesso")
        return data

    except requests.exceptions.RequestException as e:
        logging.error(f"Erro na requisição da API: {e}")
        return []

    except Exception as e:
        logging.error(f"Erro inesperado durante a extração: {e}")
        return []