#!/bin/sh

CHEFDK_PKG='chefdk_4.12.0-1_amd64.deb'
CHEFDK_SHA256='04f4a52eb287f076c7be3539d975e665dce686714c097a6716a85d4e6eb65e8e'

command -v berks >/dev/null 2>&1 || {
  echo 'Updating APT repositories...'
  apt-get update -qq

  cd /tmp

  [ ! -f "${CHEFDK_PKG}" ] && {
    echo 'Downloading Chef Development Kit...'

    wget --quiet "https://packages.chef.io/files/stable/chefdk/4.12.0/ubuntu/18.04/${CHEFDK_PKG}"

    dl_sha256="$(sha256sum /tmp/${CHEFDK_PKG} | awk '{ print $1 }')"

    if [ "${CHEFDK_SHA256}" != "${dl_sha256}" ]; then
      echo 'Chef Development Kit download checksum mismatch!'
      echo "Expected: ${CHEFDK_SHA256}"
      echo "Received: ${dl_sha256}"

      exit 1
    fi
  }

  dpkg -i "${CHEFDK_PKG}"
  rm -f "${CHEFDK_PKG}"
}

echo 'Updating Chef dependencies...'

cd /vagrant && berks vendor
