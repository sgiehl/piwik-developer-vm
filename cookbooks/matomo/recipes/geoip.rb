# install some packages required to build GeoIP2 database files (mmdb)
# required to run /matomo/tests/lib/geoip-files/writeTestFiles.pl
include_recipe 'build-essential::default'
build_essential 'install compilation tools' # required to compile modules

include_recipe 'perl::default'
cpan_module 'MaxMind::DB::Writer::Serializer'
cpan_module 'File::Slurper'
cpan_module 'Cpanel::JSON::XS'