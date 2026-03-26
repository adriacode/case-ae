import os
from datetime import datetime
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from dotenv import load_dotenv

import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

load_dotenv()
connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
if not connection_string:
    raise ValueError("Variável de ambiente AZURE_STORAGE_CONNECTION_STRING não definida.")

container_name = "datalakecaseae" 

# Cria o cliente do BlobServiceClient usando a connection string
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

def upload_file_to_blob(local_file_path, blob_file_name):
    
    blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_file_name)

    if not os.path.exists(local_file_path):
        raise FileNotFoundError(f"{local_file_path} não encontrado")

    logging.info(f"Subindo {local_file_path} → {blob_file_name}")

    # Lê o arquivo e modo binário e faz upload para o Blob Storage
    with open(local_file_path, "rb") as data:
        blob_client.upload_blob(data, overwrite=True)

    logging.info("Upload completo.")
