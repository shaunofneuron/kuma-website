#!/bin/sh

# Copyright 2019-2020 Kong Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# You can customize the version of Kuma (or Kuma-based products) to
# download by setting the VERSION environment variable, and you can change
# the default 64bit architecture by setting the ARCH variable.

DIR="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"

: "${VERSION:=}"
: "${ARCH:=amd64}"
: "${PRODUCT_NAME:=Kuma}"
: "${LATEST_VERSION:=https://kuma.io/latest_version}"
: "${REPO_PREFIX:=kuma}"
: "${CTL_NAME:=kumactl}"

printf "\n"
printf "INFO\tWelcome to the %s automated download!\n" "$PRODUCT_NAME"

if ! type "grep" > /dev/null 2>&1; then
  printf "ERROR\tgrep cannot be found\n"
  exit 1;
fi
if ! type "curl" > /dev/null 2>&1; then
  printf "ERROR\tcurl cannot be found\n"
  exit 1;
fi
if ! type "tar" > /dev/null 2>&1; then
  printf "ERROR\ttar cannot be found\n"
  exit 1;
fi
if ! type "gzip" > /dev/null 2>&1; then
  printf "ERROR\tgzip cannot be found\n"
  exit 1;
fi

DISTRO=""
OS=$(uname -s)
if [ "$OS" = "Linux" ]; then
  DISTRO=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
  if [ "$DISTRO" = "amzn" ]; then
    DISTRO="centos"
  fi
elif [ "$OS" = "Darwin" ]; then
  DISTRO="darwin"
else
  printf "ERROR\tOperating system %s not supported by %s\n" "$OS" "$PRODUCT_NAME"
  exit 1
fi

if [ -z "$DISTRO" ]; then
  printf "ERROR\tUnable to detect the operating system\n"
  exit 1
fi

DETECTED_ARCH=$(uname -m)
if [ "$ARCH" = "" ]; then
  if [ "$DETECTED_ARCH" = "x86_64" ]; then
    ARCH=amd64
  elif [ "$DETECTED_ARCH" = "arm64" ] || \
    [ "$DETECTED_ARCH" = "arch64" ] || \
    [ "$DETECTED_ARCH" = "armv8l" ] || \
    [ "$DETECTED_ARCH" = "armv8b" ]; then
    ARCH=arm64
  else
    printf "ERROR\tArchitecture %s not supported by %s\n" "$DETECTED_ARCH" "$PRODUCT_NAME"
    exit 1
  fi
fi

if [ -z "$VERSION" ]; then
  # Fetching latest version
  printf "INFO\tFetching latest %s version..\n" "$PRODUCT_NAME"

  if ! VERSION=$(curl -s $LATEST_VERSION); then
    printf "ERROR\tUnable to fetch latest %s version.\n" "$PRODUCT_NAME"
    exit 1
  fi

  if [ -z "$VERSION" ]; then
    printf "ERROR\tUnable to fetch latest %s version because of a problem with %s.\n" "$PRODUCT_NAME" "$PRODUCT_NAME"
    exit 1
  fi
fi

printf "INFO\t$PRODUCT_NAME version: %s\n" "$VERSION"
printf "INFO\t$PRODUCT_NAME architecture: %s\n" "$ARCH"
printf "INFO\tOperating system: %s\n" "$OS"
if [ "$OS" = "Linux" ]; then
    printf "INFO\tDistribution: %s\n" "$DISTRO"
fi

URL="https://download.konghq.com/mesh-alpine/$REPO_PREFIX-$VERSION-$DISTRO-$ARCH.tar.gz"

if ! curl -s --head "$URL" | head -n 1 | grep -E 'HTTP/1.1 [23]..|HTTP/2 [23]..' > /dev/null; then
  # shellcheck disable=SC2034
  IFS=. read -r major minor patch <<EOF
${VERSION}
EOF

  # handle the kumactl archive
  if [ "$OS" = "Linux" ]; then
      if  [ "$major" -ge "1" ] && [ "$minor" -ge "7" ]; then
          printf "INFO\tWe don't compile the %s executables for your Linux distribution.\n" "$PRODUCT_NAME"
          printf "INFO\tFetching %s...\n" "$CTL_NAME"
          URL="https://download.konghq.com/mesh-alpine/$REPO_PREFIX-$CTL_NAME-$VERSION-linux-$ARCH.tar.gz"
          if ! curl -s --head "$URL" | head -n 1 | grep -E 'HTTP/1.1 [23]..|HTTP/2 [23]..' > /dev/null; then
            printf "ERROR\tUnable to download %s at the following URL: %s\n" "$CTL_NAME" "$URL"
            exit 1
          fi
      else
        printf "WARNING\tYou appear to be running an unsupported Linux distribution.\n"
      fi
  fi
  printf "ERROR\tUnable to download %s at the following URL: %s\n" "$PRODUCT_NAME" "$URL"
  exit 1
fi

printf "INFO\tDownloading %s from: %s" "$PRODUCT_NAME" "$URL"
printf "\n\n"

if curl -L "$URL" | tar xz; then
  printf "\n"
  printf "INFO\t%s %s has been downloaded!\n" "$PRODUCT_NAME" "$VERSION"
  printf "\n"
  printf "%s" "$(cat "$DIR/$REPO_PREFIX-$VERSION/README")"
  printf "\n"
else
  printf "\n"
  printf "ERROR\tUnable to download %s\n" "$PRODUCT_NAME"
  exit 1
fi
