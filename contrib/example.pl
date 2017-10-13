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

print "\n";

for my $rep (@{$drc->repositories()}) {
  print "- Found repository $rep\n";
  for my $tag (@{$drc->list_tags($rep)}) {
    print "-- Found tag $tag\n";
    my $manifest = $drc->manifests($rep, $tag);
    print "  Name : $manifest->{name}\n";
    print "  Tag  : $manifest->{tag}\n";
    print "  Arch : $manifest->{architecture}\n";
    print "  Layers:\n";
    foreach my $layer (@{$manifest->{fsLayers}}) {
      print "   - $layer->{blobSum}\n";
    }
  }
  print "\n\n";
}



exit 0;
