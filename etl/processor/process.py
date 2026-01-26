
import os
import pandas as pd
from glob import glob
FREQUENCY='1m'

BASE_DIR = f"C:/Myfiles/etl/data/raw_data/binance_{FREQUENCY}_daily_klines_futures"
#BASE_DIR = f"/data/raw_data/binance_{FREQUENCY}_daily_klines_futures"
print(BASE_DIR)

OUTPUT_CSV = f"C:/Myfiles/etl/data/processed_data/binance_{FREQUENCY}_daily_klines_futures"
#OUTPUT_CSV = f"/data/processed_data/binance_{FREQUENCY}_daily_klines_futures"



csv_files = sorted(glob(os.path.join(BASE_DIR, "**", "*.csv"), recursive=True))
print(f"🔍 Found {len(csv_files)} csv files")

if not csv_files:
    raise SystemExit("No csv files found – check BASE_DIR")

good_dfs = []
bad_files = []
total_bytes = 0

columns_name = []
for path in csv_files:
    try:

        #   “…\\BTCUSDT\\BTCUSDT-1m-2025-01.csv”

        filename = path.split(f"\\")[-1]
        filename1 = (filename[:-4])
        year = filename1.split(f"-")[-2]
        month = filename1.split(f"-")[-1]

        if 1:
            total_bytes += os.path.getsize(path)
            symbol = os.path.basename(os.path.dirname(path))

            df = pd.read_csv(path)
            df["symbol"] = symbol
            columns_name = df.columns.tolist()
            good_dfs.append(df)
    except Exception as e:
        print(f"⚠️  bad file: {path}  ({e})")
        bad_files.append(path)



print(len(good_dfs), "good files to merge")
total_gb = total_bytes / (1024 ** 3)
print("total_gb: ", (total_gb))

if os.path.exists(OUTPUT_CSV):
    os.remove(OUTPUT_CSV)
    print(f"🗑️ Deleted existing file: {OUTPUT_CSV}")
else:
    print(f"⚠️ File not found: {OUTPUT_CSV}")

for df in good_dfs:
    df.to_csv(OUTPUT_CSV, mode="a", index=False)

# if good_dfs:
#    merged = pd.concat(good_dfs, ignore_index=True)
#    merged.to_csv(OUTPUT_CSV, index=False)
#    print(f"✅ merged {len(good_dfs)} good files → {OUTPUT_CSV}")
# else:
#    print("❗ No valid csv to merge")

