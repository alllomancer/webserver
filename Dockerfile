FROM golang:1.18  AS builder
WORKDIR /go/src/github.com/alllomancer/webserver
ADD . /go/src/github.com/alllomancer/webserver
RUN cd /go/src/github.com/alllomancer/webserver

RUN go test .
RUN go build -o /app/webserver .
RUN chmod +x /go/src/github.com/alllomancer/webserver/ldd-cp.sh
RUN /go/src/github.com/alllomancer/webserver/ldd-cp.sh ldd-cp  /app/webserver /temp


# Create a small image
FROM busybox AS default-image

COPY --from=builder /temp/ /
CMD /app/webserver