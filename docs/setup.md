## 🧩 システム構成 / System Architecture

Azazelは以下のコンポーネントで構成されます：  
*Azazel is composed of the following components:*

- OpenCanary（ハニーポットサービス） / Honeypot service
- Vector（ログ収集と転送） / Log collection and forwarding
- PostgreSQL（Mattermost用DB） / Database for Mattermost
- Mattermost（通知UI） / Notification and collaboration UI

各サービスはDockerコンテナ上で稼働し、ホスト上で制御・通知連携が可能です。  
*All components run in Docker containers and are managed and integrated via the host system.*

---

## ⚙️ 設定ファイルの説明 / Configuration Files

### `/opt/azazel/config/opencanary.conf`
- 各種疑似サービス（SSH, HTTPなど）の有効化・ログ出力設定  
  *Enables simulated services like SSH/HTTP and sets log output settings.*
- `device.node_id` は一意な識別子  
  *`device.node_id` must be unique for each instance.*

### `/opt/azazel/config/vector.toml`
- Vectorが収集するログソース（例：OpenCanaryログ、Suricataログ）  
  *Defines sources Vector will collect logs from (e.g., OpenCanary, Suricata).* 
- 出力先はコンソール、ファイル、もしくは将来的にSIEM連携  
  *Output can be console, file, or eventually a SIEM system.*

### `/opt/mattermost/config/config.json`
- `install_azazel.sh` により `SiteURL` や `DataSource` が自動設定される  
  *`install_azazel.sh` automatically configures `SiteURL` and `DataSource`.*
- 手動でSMTPやファイルストレージなど追加設定可能  
  *You can manually configure SMTP, file storage, etc.*

---

## 🚦 起動順と依存関係 / Startup Sequence and Dependencies

- `/opt/azazel/config/*` の設定ファイルは `docker-compose up` の**前に配置**する必要があります  
  *Configuration files must be placed before running `docker-compose up`.*
- Mattermost は PostgreSQL が `Up` になってから systemd 経由で起動  
  *Mattermost requires PostgreSQL to be running before its own startup.*
- `config.json` 編集後は `chown/chmod` を適切に行わないと起動失敗します  
  *Ensure `config.json` has correct ownership and permissions after editing.*

---

## 🛠️ カスタマイズ例 / Customization Examples

- `docker-compose.yml` 内の IP アドレスを固定化（例：172.16.10.10）  
  *Set static IP addresses in `docker-compose.yml` (e.g., 172.16.10.10).* 
- OpenCanary のサービス追加（Telnet, SMBなど）  
  *Enable additional OpenCanary services (e.g., Telnet, SMB).* 
- Vector のログ出力形式を JSON → text に変更  
  *Change Vector log output format from JSON to plain text.*

---

## 🧪 トラブルシュート / Troubleshooting

| 問題 / Problem | 原因 / Cause | 解決策 / Solution |
|------|------|--------|
| OpenCanary が Restarting を繰り返す / OpenCanary keeps restarting | `/root/.opencanary.conf` がディレクトリ / It is a directory | `rm -rf` して再起動 / Remove and restart |
| Vector が `is a directory` エラー / Vector "is a directory" error | `/etc/vector/vector.toml` が誤ってディレクトリ / It is incorrectly a directory | 正しいファイルを再配置 / Replace with correct file |
| Mattermost 起動失敗 `exit-code` / Mattermost fails with exit-code | `config.json` のパーミッション or DB接続誤り / Permission or DB access error | `chown` + `azazel_postgres` に修正 / Fix ownership and DB host |

---

## 🔁 メンテナンスと更新 / Maintenance

- Suricataルール更新：  
  *Update Suricata rules:*
```bash
sudo suricata-update
```

- コンテナの再起動：  
  *Restart containers:*
```bash
cd /opt/azazel/containers
sudo docker-compose down && sudo docker-compose up -d
```

- Mattermostのログ確認：  
  *Check Mattermost logs:*
```bash
sudo journalctl -u mattermost -e
```

---

## 📘 その他 / Notes

- `.env` や `.local` 設定などを活用することで、構成をより柔軟にできます  
  *You can further customize the setup using `.env` or `.local` files.*
- Mattermostの管理者アカウント作成は初回ブラウザアクセス時に行います  
  *Create the Mattermost admin account via the browser on first access.*

For advanced use, consider adjusting `.env` or mounting your own configuration volume.

