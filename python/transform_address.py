import pandas as pd
import ast
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


def create_dataframe(file_path):
    """
    Cria um DataFrame a partir de um arquivo CSV.

    Parâmetros:
        file_path (str): Caminho do arquivo CSV.

    Retorno:
        DataFrame: DataFrame carregado.
    """
    try:
        logging.info("Criando DataFrame a partir do arquivo CSV...")

        df = pd.read_csv(file_path)

        logging.info(f"DataFrame criado com {len(df)} linha(s)")
        return df

    except Exception as e:
        logging.error(f"Erro ao criar DataFrame: {e}")
        return pd.DataFrame()


def normalize_address(df):
    """
    Normaliza a coluna 'address' expandindo os campos em colunas separadas.

    Parâmetros:
        df (DataFrame): DataFrame contendo a coluna 'address'.

    Retorno:
        DataFrame: DataFrame com endereço normalizado.
    """
    try:
        if "address" not in df.columns:
            logging.warning("Coluna 'address' não encontrada no DataFrame")
            return df

        logging.info("Normalizando coluna 'address'...")

        # Converte string para dicionário de forma segura
        def safe_parse(x):
            try:
                return ast.literal_eval(x) if isinstance(x, str) else x
            except Exception:
                return {}

        df["address"] = df["address"].apply(safe_parse)

        df_address = pd.json_normalize(df["address"])

        # Remove coluna desnecessária
        if "id" in df_address.columns:
            df_address = df_address.drop(columns=["id"])

        df = pd.concat([df, df_address], axis=1).drop(columns=["address"])

        logging.info(
            f"Endereço normalizado. DataFrame final com {len(df)} linha(s) e {len(df.columns)} coluna(s)"
        )

        return df

    except Exception as e:
        logging.error(f"Erro ao normalizar endereço: {e}")
        return df