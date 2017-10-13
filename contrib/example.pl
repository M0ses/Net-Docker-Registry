#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use YAML;
use Data::Dumper;

BEGIN { unshift @::INC, "$FindBin::Bin/../lib" };

use Net::Docker::Registry::Client;

my $config = YAML::LoadFile("$FindBin::Bin/../etc/config.yml");
my $drc = Net::Docker::Registry::Client->new(%$config);

for my $rep (@{$drc->repositories()}) {
  for my $tag (@{$drc->list_tags($rep)}) {
    print Dumper($drc->manifests($rep, $tag));
  }
}



exit 0;
