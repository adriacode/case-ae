from extract_hr_personal_data import extract_data
from transform_address import create_dataframe, normalize_address
from ingest_data_blob_storage import upload_file_to_blob

from datetime import datetime
import pandas as pd
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


def main():
    """
    Executa o pipeline completo de ingestão de dados:

    1. Extrai dados da API
    2. Salva dados temporários
    3. Aplica transformações
    4. Gera arquivo final
    5. Realiza upload para o Data Lake (camada Bronze)
    """

    try:
        API_URL = "https://fakerapi.it/api/v1/persons?_quantity=1000"
        NUM_REQUESTS = 3

        TEMP_FILE = "./data/hr_personal_temp.csv"
        FINAL_FILE = "./data/hr_personal.csv"
        CORPORATE_FILE = "./data/hr_corporate.xlsx"

        # -----------------------
        # EXTRAÇÃO
        # -----------------------
        logging.info("Iniciando extração de dados...")

        all_data = []

        for i in range(NUM_REQUESTS):
            data = extract_data(API_URL)
            all_data.extend(data)

        logging.info(f"Total de dados extraídos: {len(all_data)}")

        # -----------------------
        # SALVANDO TEMP
        # -----------------------
        df = pd.DataFrame(all_data)
        df.to_csv(TEMP_FILE, index=False)

        # -----------------------
        # TRANSFORMAÇÃO
        # -----------------------
        logging.info("Iniciando transformação dos dados...")

        df = create_dataframe(TEMP_FILE)
        df = normalize_address(df)

        df.to_csv(FINAL_FILE, index=False)

        # -----------------------
        # INGESTÃO (BRONZE)
        # -----------------------
        ingestion_date = datetime.now().strftime("ingestion_date=%Y-%m-%d")

        logging.info("Iniciando upload para o Data Lake...")

        upload_file_to_blob(
            FINAL_FILE,
            f"bronze/hr_personal/{ingestion_date}/hr_personal.csv"
        )

        upload_file_to_blob(
            CORPORATE_FILE,
            f"bronze/hr_corporate/{ingestion_date}/hr_corporate.xlsx"
        )

        logging.info("Pipeline executado com sucesso!")

    except Exception as e:
        logging.error(f"Erro na execução do pipeline: {e}")


if __name__ == "__main__":
    main()