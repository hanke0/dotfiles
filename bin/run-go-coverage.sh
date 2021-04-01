#!/usr/bin/env bash

go test -gcflags=all=-l -coverprofile=cover.out ./... &&
    go tool cover -html=cover.out -o cover.html
