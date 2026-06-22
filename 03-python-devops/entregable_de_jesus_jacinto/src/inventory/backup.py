import subprocess

def backup_etc(host):

    command = (
        f'tar czf - /etc | '
        f'ssh backup@{host} '
        f'"cat > backup-{host}.tar.gz"'
    )

    subprocess.run(command, shell=True)

    print(f"Backup realizado en {host}")

