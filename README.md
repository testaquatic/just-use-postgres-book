# "그냥 Postgres를 쓰세요!"를 읽으면서 작성한 코드

1. DB 생성
```bash
# 볼륨 생성
docker volume create postgres-volume
# 실행
docker run --name postgres \
        -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password \
        -p 5432:5432 \
        -v postgres-voluem:/var/lib/postgresql/18/docker \
        -d postgres:latest
```