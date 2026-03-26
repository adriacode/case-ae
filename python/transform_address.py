import json
import pandas as pd
import ast

import logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def create_dataframe(file_path:str) -> pd.DataFrame:
    logging.info("→ Criando Datafrane do arquivo CSV...")
    
    df = pd.read_csv(file_path)
    logging.info(f"\n✓ Dataframe criado com {len(df)} linha(s)")
    return df

def normalize_address(df: pd.DataFrame) -> pd.DataFrame:
        
    df["address"] = df["address"].apply(ast.literal_eval)

    df_address = pd.json_normalize(df['address'])
    
    if "id" in df_address.columns:
        df_address = df_address.drop(columns=["id"])
    
    df = pd.concat([df, df_address], axis=1).drop(columns=['address'])
    logging.info(f"✓ Colunas de address normalizada. DataFrame final com {len(df)} linha(s) e {len(df.columns)} coluna(s)")    
    return df