# One Postgres node managed by Patroni: it initialises or clones the database, keeps a leader lock in
# etcd, streams from the leader as a replica, and promotes itself when the leader is gone.
FROM postgres:16-bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 python3-venv curl \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m venv /opt/patroni \
 && /opt/patroni/bin/pip install --no-cache-dir 'patroni[etcd3,psycopg3]==4.0.11' \
 && ln -s /opt/patroni/bin/patroni /opt/patroni/bin/patronictl /usr/local/bin/

COPY patroni.yml /etc/patroni/patroni.yml
COPY entrypoint.sh post_bootstrap.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/entrypoint.sh /usr/local/bin/post_bootstrap.sh \
 && mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql /etc/patroni

USER postgres
# 5432 Postgres, 8008 Patroni's REST API (/primary, /replica, /health, /metrics).
EXPOSE 5432 8008
HEALTHCHECK --interval=5s --timeout=3s --start-period=30s --retries=10 \
  CMD curl -fs http://127.0.0.1:8008/health >/dev/null || exit 1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
