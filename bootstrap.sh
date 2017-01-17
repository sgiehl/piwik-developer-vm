#!/bin/sh

CHEFDK_PKG='chefdk_1.1.16-1_amd64.deb'
CHEFDK_SHA256='7a1bed7f6eae3ae26694f9d3f47ce76d5e0cbbaba72dafcbc175e89ba0ac6dd9'

command -v berks >/dev/null 2>&1 || {
  echo 'Updating APT repositories...'
  apt-get update -qq

  cd /tmp

  [ ! -f "${CHEFDK_PKG}" ] && {
    echo 'Downloading Chef Development Kit...'

    wget --quiet "https://packages.chef.io/files/stable/chefdk/1.1.16/ubuntu/14.04/${CHEFDK_PKG}"

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

cd /vagrant/cookbooks/piwik && berks vendor
