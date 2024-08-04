import pandas as pd

json_file_path = "file.json"
df = pd.read_json(json_file_path)

parquet_file_path = "output.parquet"

df.to_parquet(parquet_file_path, engine="pyarrow")
