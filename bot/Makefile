.PHONY:

build:
	go build -o ./bin/bot cmd/bot/main.go

run: build
	./bin/bot

build-image:
	docker build  -t swopin-bot:v0.1. .

start-cont:
	docker run --env-file .env -p 23333:23333 swopin-bot:v0.1.