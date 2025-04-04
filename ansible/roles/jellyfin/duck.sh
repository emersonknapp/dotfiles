#!/bin/bash
set -euxo pipefail

echo url="https://www.duckdns.org/update?domains=snarkworksjellyfin&token=a525ceeb-5e68-4d3c-8b66-79e8b2356fa0&ip=" | curl -k -o ~/dev/duckdns/duck.log -K -
