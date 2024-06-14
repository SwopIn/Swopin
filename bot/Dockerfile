FROM golang:1.22-alpine3.19 AS builder

RUN go version

COPY . /github.com/AlexAntonik/Swopin/bot/
WORKDIR /github.com/AlexAntonik/Swopin/bot/

RUN go mod download
RUN GOOS=linux go build -o ./bin/bot ./bot/main.go ./bot/utils.go ./bot/db_triggers.go

FROM alpine:latest

WORKDIR /root/

COPY --from=0 /github.com/AlexAntonik/Swopin/bot/bin/bot/ .
COPY --from=0 /github.com/AlexAntonik/Swopin/bot/config config/
#80???
EXPOSE 23333
EXPOSE 23334:23334

CMD ["./bot"]
