#!/bin/sh

# Some indexers are protected by CloudFlare or similar services and Jackett is not able to solve the challenges.
# For these cases, FlareSolverr has been integrated into Jackett.
# This service is in charge of solving the challenges and configuring Jackett with the necessary cookies.

# https://github.com/FlareSolverr/FlareSolverr?tab=readme-ov-file#installation
docker run -d \
	--name=flaresolverr \
	-p 8191:8191 \
	-e LOG_LEVEL=info \
	--restart unless-stopped \
	ghcr.io/flaresolverr/flaresolverr:latest
