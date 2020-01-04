name 'matomo'
license 'Apache-2.0'
description 'Installs Matomo.'
version '1.0.0'
chef_version '>= 12.0' if respond_to?(:chef_version)
supports 'ubuntu'

maintainer 'John Doe'
maintainer_email 'john@doe'
issues_url 'http://github.com'
source_url 'http://github.com'

depends 'apache2'
depends 'apt'
depends 'build-essential'
depends 'composer'
depends 'packagecloud'
depends 'redisio'
depends 'chrome'
depends 'nodejs'
depends 'nvm'
depends 'imagemagick'
depends 'perl'
