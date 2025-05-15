#!/bin/bash
# Dockerネットワークとコンテナ間通信を診断するスクリプト

echo "===== コンテナの状態 ====="
docker ps

echo
echo "===== Elasticsearchの状態 ====="
curl -s -u elastic:elastic http://localhost:9200 | grep -v password

echo
echo "===== Dockerネットワークの一覧 ====="
docker network ls

echo
echo "===== siem-networkの詳細 ====="
docker network inspect siem-network

echo
echo "===== Vectorコンテナからの接続テスト ====="
echo "* ping to elastic:"
docker exec siem-vector-1 ping -c 2 elastic

echo "* curl to elastic:"
docker exec siem-vector-1 wget -q -O- --timeout=2 --user=elastic --password=elastic http://elastic:9200 || echo "Connection failed"

echo
echo "===== Elasticsearchのログ（最後の10行） ====="
docker logs --tail 10 elastic