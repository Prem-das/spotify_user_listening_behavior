import os
import json
import glob
import pandas as pd

# for filename in os.listdir(os.getcwd()):
#     if filename.endswith('.json'):
#         file_name_without_ext = os.path.splitext(filename)[0]
        
#         try:
#             with open(filename, 'r', encoding='utf-8') as f:
#                 data = json.load(f)
            
#             # json_normalize flattens nested keys (e.g., user.address.city becomes user_address_city)
#             df = pd.json_normalize(data)
            
#             df.to_csv(f"{file_name_without_ext}.csv", index=False)
#             print(f"Successfully flattened and converted: {filename}")
#         except Exception as e:
#             print(f"Error converting {filename}: {e}")


# merging all the csv files

df = pd.concat(map(pd.read_csv, glob.glob('*.csv')), ignore_index=True)
df.to_csv('combined_output.csv', index=False)