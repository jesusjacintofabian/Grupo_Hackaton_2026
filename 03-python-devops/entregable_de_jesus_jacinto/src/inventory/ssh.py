import paramiko

def collect_server_info(host, username, key_file):

    client = paramiko.SSHClient()

    client.set_missing_host_key_policy(
        paramiko.AutoAddPolicy()
    )

    try:

        client.connect(
            hostname=host,
            username=username,
            key_filename=key_file,
            timeout=10
        )

        commands = {
            "hostname": "hostname",
            "kernel": "uname -r",
            "cpu": "nproc",
            "ram": "free -h | grep Mem | awk '{print $2}'"
        }

        results = {}

        for key, cmd in commands.items():
            stdin, stdout, stderr = client.exec_command(cmd)
            results[key] = stdout.read().decode().strip()

        return results

    finally:
        client.close()

