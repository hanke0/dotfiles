#!/usr/bin/env bash

# Update go direct dependences
go list -f '{{if not .Indirect}}{{.}}{{end}}' -u -m all | tr ' ' '@' | grep @ | xargs -t -I {} go get {}
