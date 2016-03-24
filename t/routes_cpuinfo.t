use strict;
use warnings;
use Test::More;
use Test::Clustericious::Cluster;
use Path::Class qw( file );

do { no warnings; $WebProc::CpuInfo::filename = file(qw( corpus proc cpuinfo ))->absolute->stringify };

my $cluster = Test::Clustericious::Cluster->new;
$cluster->create_cluster_ok('WebProc');
my $t = $cluster->t;

$t->get_ok('/cpuinfo')
  ->status_is(200)
  ->json_is('/1/processor', 1)
  ->json_like('/1/url', qr{^http://.*/cpuinfo/1$});

$t->get_ok('/cpuinfo/2')
  ->status_is(200)
  ->json_is('/processor', 2)
  ->json_is('/address sizes', '36 bits physical, 48 bits virtual');

$t->get_ok('/cpuinfo/5')
  ->status_is(404);

done_testing;

__DATA__

@@ etc/WebProc.conf
---
url: <%= cluster->url %>
