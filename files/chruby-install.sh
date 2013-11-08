#!/bin/bash

VERSION_NAME=$1
VERSIONS_DIR="${CHRUBY_ROOT}/versions"

/bin/mkdir -p $VERSIONS_DIR

if [ -z "$SKIP_PRECOMPILED_RUBIES" ]; then
  PLATFORM="$(/bin/uname -s | /usr/bin/tr '[:upper:]' '[:lower:]')"

  if [ "$PLATFORM" = "darwin" ]; then
    OS_RELEASE=`/usr/bin/sw_vers -productVersion | /usr/bin/cut -f 1-2 -d '.'`
  else
    if [ -x "/usr/bin/lsb_release" ]; then
      OS_RELEASE="$(/usr/bin/lsb_release --codename --short)"
    fi
  fi

  if [ -z "$OS_RELEASE" ]; then
    echo "There are no precompiled binaries for this operating system" >2
    return
  fi

  DOWNLOAD_BUCKET=${BOXEN_S3_BUCKET-"boxen-downloads"}
  DOWNLOAD_HOST=${BOXEN_S3_HOST-"s3.amazonaws.com"}

  echo "Trying to download precompiled Ruby from S3..."
  curl --silent --fail http://$DOWNLOAD_HOST/$DOWNLOAD_BUCKET/chruby/$PLATFORM/$OS_RELEASE/$VERSION_NAME.tar.bz2 \
    | tar jxf -C $VERSIONS_DIR

  if [ -d "$VERSIONS_DIR/$VERSION_NAME" ]; then
    # install from download was successful
    exit 0
  fi
fi

ruby-build $VERSION_NAME $VERSIONS_DIR/$VERSION_NAME