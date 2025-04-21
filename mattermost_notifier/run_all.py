import threading
import subprocess

def run_suricata():
    subprocess.run(["python3", "mattermost_notifier/main_suricata.py"])

def run_opencanary():
    subprocess.run(["python3", "mattermost_notifier/main_opencanary.py"])

if __name__ == "__main__":
    print("🚀 Starting unified monitor...")
    threading.Thread(target=run_suricata).start()
    threading.Thread(target=run_opencanary).start()
