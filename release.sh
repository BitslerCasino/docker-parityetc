#!/usr/bin/env bash

# this is used along side github-release. install it via go get github.com/aktau/github-release
VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Missing version"
  exit;
fi

github-release release \
    --user bitslercasino \
    --repo docker-parityetc \
    --tag v$VERSION \
    --name "v$VERSION Stable Release" \
    --description "openethereum"

github-release upload \
    --user bitslercasino \
    --repo docker-parityetc \
    --tag v$VERSION \
    --name "install.sh" \
    --file install.sh

github-release upload \
    --user bitslercasino \
    --repo docker-parityetc \
    --tag v$VERSION \
    --name "utils.sh" \
    --file utils.sh

sed -i "s/docker-parityetc\/releases\/download\/.*\/install\.sh/docker-parityetc\/releases\/download\/v$VERSION\/install\.sh/g" README.md
sed -i "s/docker-parityetc\/releases\/download\/.*\/utils\.sh/docker-parityetc\/releases\/download\/v$VERSION\/utils\.sh/g" README.md
sed -i "s/openetc-update .*\`/openetc-update $VERSION\`/g" README.md