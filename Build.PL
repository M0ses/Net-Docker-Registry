use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Net::Docker::Registry',
    license             => 'artistic_2',
    dist_author         => q{Frank Schreiner <m0ses@samaxi.de>},
    dist_version_from   => 'lib/Net/Docker/Registry.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => '0',
    },
    build_requires => {
        'Test::More' => '0',
    },
    requires => {
      'LWP::UserAgent',
      'HTTP::Request',  
      'JSON::XS',
      'URI::Escape',
    },
    add_to_cleanup     => [ 'Net-Docker-Registry-*' ],
);

$builder->create_build_script();
