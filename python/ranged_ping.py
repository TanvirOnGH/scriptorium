import subprocess
import ipaddress
import sys
import re

DEFAULT_START_IP = "10.244.242.0"
DEFAULT_END_IP = "10.244.242.255"
DEFAULT_TIMEOUT = 1


def ping_ip(ip, timeout):
    try:
        output = subprocess.check_output(
            ["ping", "-c", "1", str(ip)], timeout=timeout, universal_newlines=True
        )
        match = re.search(r"time=(\d+\.?\d*)", output)
        if match:
            return float(match.group(1))
    except subprocess.TimeoutExpired:
        pass
    except subprocess.CalledProcessError:
        pass
    return None


def find_accessible_ip(
    start_ip=DEFAULT_START_IP, end_ip=DEFAULT_END_IP, timeout=DEFAULT_TIMEOUT
):
    accessible_count = 0
    inaccessible_count = 0
    total_time = 0
    average_time = 0

    total_ips_in_range = (
        int(ipaddress.IPv4Address(end_ip)) - int(ipaddress.IPv4Address(start_ip)) + 1
    )

    for ip in range(
        int(ipaddress.IPv4Address(start_ip)), int(ipaddress.IPv4Address(end_ip)) + 1
    ):
        current_ip = ipaddress.IPv4Address(ip)
        if current_ip.is_private:
            print(f"{current_ip}...", end=" ")
            time = ping_ip(current_ip, timeout)
            if time is not None:
                print(f"Accessible! Time: {time} ms")
                accessible_count += 1
                total_time += time
            else:
                print(f"Inaccessible!")
                inaccessible_count += 1

    if accessible_count > 0:
        average_time = total_time / accessible_count

    print("")
    print("Summary:")
    print(f"IP addresses in range: {total_ips_in_range}")
    print(f"Accessible IPs: {accessible_count} ({average_time:.2f} ms average)")
    print(f"Inaccessible IPs: {inaccessible_count}")


if __name__ == "__main__":
    if len(sys.argv) == 1:
        find_accessible_ip()
    elif len(sys.argv) == 4:
        start_ip = sys.argv[1]
        end_ip = sys.argv[2]
        timeout = float(sys.argv[3])
        find_accessible_ip(start_ip, end_ip, timeout)
    else:
        print("Missing required arguments: [start_ip end_ip timeout]")
        sys.exit(1)
