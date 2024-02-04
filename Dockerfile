# syntax=docker/dockerfile:1

##
## Build the application from source
##

FROM golang:1.20 AS build-stage

#ARG app_version
#ENV version=$app_version

WORKDIR /app

##
## Copy files
##
COPY go.mod ./
RUN go mod download

RUN mkdir -p ./src/server ./build 
COPY src/server/*.go ./src/server/
COPY src/*.go ./src/
COPY build/make_binaries.sh ./build/
COPY build/timedrop.spect ./build/

##
## Build the executable
##
#
RUN ./build/make_binaries.sh --silent
RUN mv -f ./bin/timedrop /timedrop
RUN rm -rf ./bin
#RUN -e CGO_ENABLED=0 GOOS=linux go build -o /timedrop -ldflags "-X main.Version=$version" ./src/server/server.go
#RUN CGO_ENABLED=0 GOOS=linux go build -o /timedrop ./src/server/server.go

##
## Run the tests in the container
##

FROM build-stage AS run-test-stage
RUN go test -v ./...

##
## Deploy the application binary into a lean image
##

FROM gcr.io/distroless/base-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /timedrop /timedrop

EXPOSE 9987

USER nonroot:nonroot

ENTRYPOINT ["/timedrop", "--container"]
