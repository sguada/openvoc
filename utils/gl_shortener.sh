#!/bin/bash
curl https://www.googleapis.com/urlshortener/v1/url -H '''Content-Type: application/json''' -d ''''{"longUrl"': '"'$1'"}''
