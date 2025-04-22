FROM golang:1.24.0-alpine AS builder

COPY . /vkatun/source/
WORKDIR /vkatun/source/

RUN go mod download
RUN go build -o ./bin/app cmd/main.go

FROM alpine:latest

WORKDIR /root/
COPY --from=builder /vkatun/source/bin/app .

EXPOSE 8080

CMD ["./app"]