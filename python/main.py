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
    all_data = []
    for i in range(3):
        data = extract_data("https://fakerapi.it/api/v1/persons?_quantity=1000")
        all_data.extend(data)
    logging.info(f"Total de dados extraídos: {len(all_data)}")

    df = pd.DataFrame(all_data)
    df.to_csv('./data/hr_personal_temp.csv', index=False)

    df = create_dataframe('./data/hr_personal_temp.csv')
    df = normalize_address(df)
    df.to_csv('./data/hr_personal.csv', index=False)

    ingestion_date = datetime.now().strftime("ingestion_date=%Y-%m-%d")
    upload_file_to_blob("data/hr_personal.csv", f"bronze/hr_personal/{ingestion_date}/hr_personal.csv")
    upload_file_to_blob("data/hr_corporate.xlsx", f"bronze/hr_corporate/{ingestion_date}/hr_corporate.xlsx")

if __name__ == "__main__":
    main()