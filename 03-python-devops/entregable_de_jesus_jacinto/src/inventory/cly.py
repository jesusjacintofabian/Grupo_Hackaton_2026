from ec2 import get_ec2_instances
from report import export_reports

def main():

    print("\nInventario AWS\n")

    inventory = get_ec2_instances()

    export_reports(inventory)

    print("\nProceso finalizado")

if __name__ == "__main__":
    main()
