import os
import logging
from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


def get_blob_service_client():
    """
    Cria e retorna o cliente do Azure Blob Storage.

    Retorno:
        BlobServiceClient: Cliente autenticado para acesso ao Blob Storage.
    """
    load_dotenv()

    connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")

    if not connection_string:
        raise ValueError("Variável de ambiente AZURE_STORAGE_CONNECTION_STRING não definida.")

    return BlobServiceClient.from_connection_string(connection_string)


def upload_file_to_blob(local_file_path, blob_file_name):
    """
    Realiza o upload de um arquivo local para o Azure Blob Storage.

    Parâmetros:
        local_file_path (str): Caminho do arquivo local.
        blob_file_name (str): Nome do arquivo no Blob Storage.
    """

    try:
        if not os.path.exists(local_file_path):
            raise FileNotFoundError(f"{local_file_path} não encontrado")

        container_name = "datalakecaseae"
        blob_service_client = get_blob_service_client()

        blob_client = blob_service_client.get_blob_client(
            container=container_name,
            blob=blob_file_name
        )

        logging.info(f"Iniciando upload: {local_file_path} → {blob_file_name}")

        with open(local_file_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)

        logging.info(f"Upload concluído com sucesso: {blob_file_name}")

    except Exception as e:
        logging.error(f"Erro ao realizar upload para o Blob Storage: {e}")