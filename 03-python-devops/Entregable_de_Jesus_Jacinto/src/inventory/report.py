import json
import pandas as pd

def export_reports(data):

    with open("inventory.json", "w") as file:
        json.dump(data, file, indent=4)

    df = pd.DataFrame(data)

    df.to_csv(
        "inventory.csv",
        index=False
    )

    df.to_excel(
        "inventory.xlsx",
        index=False
    )

    print(df.describe(include="all"))


