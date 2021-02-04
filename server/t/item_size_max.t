#!/usr/bin/perl

use strict;
use Test::More tests => 5;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $engine = shift;
my $server = get_memcached($engine);
my $sock = $server->sock;

my $stats = mem_stats($sock, ' settings');

# Ensure default still works.
is($stats->{item_size_max}, 1024 * 1024);
$server->stop();

### [ARCUS] CHANGED FOLLOWING TEST ###
# The small memory allocator allocates chunk memory from existing slab allocator.
# And, the chunk memory size is about 17MB.
# Therefore, the minimum item size is changed from 1KB to 20KB.
######################################

# Should die.
### [ARCUS] CHANGED FOLLOWING TEST ###
#eval {
#    $server = get_memcached($engine, '-I 1000');
#};
#ok($@ && $@ =~ m/^Failed/, "Shouldn't start with < 1k item max");
eval {
    $server = get_memcached($engine, '-I 20000');
};
ok($@ && $@ =~ m/^Failed/, "Shouldn't start with < 20k item max");
######################################

eval {
    $server = get_memcached($engine, '-I 256m');
};
ok($@ && $@ =~ m/^Failed/, "Shouldn't start with > 128m item max");

# Minimum.
### [ARCUS] CHANGED FOLLOWING TEST ###
#$server = get_memcached($engine, '-I 1024');
$server = get_memcached($engine, '-I 20480');
my $stats = mem_stats($server->sock, ' settings');
#is($stats->{item_size_max}, 1024);
is($stats->{item_size_max}, 20480);
$server->stop();
######################################

# Reasonable but unreasonable.
=pod
$server = get_memcached($engine, '-I 1049600');
my $stats = mem_stats($server->sock, ' settings');
is($stats->{item_size_max}, 1049600);
$server->stop();
=cut

# Suffix kilobytes.
$server = get_memcached($engine, '-I 512k');
my $stats = mem_stats($server->sock, ' settings');
is($stats->{item_size_max}, 524288);
$server->stop();

# Suffix megabytes.
=pod
$server = get_memcached($engine, '-I 32m');
my $stats = mem_stats($server->sock, ' settings');
is($stats->{item_size_max}, 33554432);
$server->stop();
=cut

# Test sets up to a large size around 2MB.
# Fot the time being, we disable the test below.
=pod
$server = get_memcached($engine, '-I 2m');
my $stats = mem_stats($server->sock, ' settings');
is($stats->{item_size_max}, 2097152);
my $added_len = 128; # keylen + item meta size
my $len = 2 * 1024 * 1024 - $added_len;
my $val = "B"x$len;
my $cmd = "set foo_$len 0 0 $len";
my $rst = "STORED";
my $msg = "stored size $len";
mem_cmd_is($server->sock, $cmd, $val, $rst);
$server->stop();
=cut

# after test
release_memcached($engine, $server);
