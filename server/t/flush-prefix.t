#!/usr/bin/perl

use strict;
use Test::More tests => 4001;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $engine = shift;
my $server = get_memcached($engine);
my $sock = $server->sock;
my $cmd;
my $val;
my $rst;
my $size;
my $count;
my $prefix_size = 1000;

sub prefix_insert {
  for ($size = 0; $size < $prefix_size; $size++) {
    $cmd = "set pname$size:foo 0 0 6"; $val = "fooval"; $rst = "STORED";
    mem_cmd_is($sock, $cmd, $val, $rst);
  }
}

sub item_get_hit {
  for ($size = 0; $size < $prefix_size; $size++) {
    $cmd = "get pname$size:foo";
    $rst = "VALUE pname$size:foo 0 6\nfooval\nEND";
    mem_cmd_is($sock, $cmd, "", $rst);
  }
}

sub count_prefix_exist {
  print $sock "stats detail dump\r\n";
  my $line = scalar <$sock>;
  $count = 0;
  while ($line =~ /^PREFIX/) {
    $count = $count + 1;
    $line = scalar <$sock>;
  }
  if ($count != $prefix_size)
  {
    croak("The number of prefixes is incorrect.");
  }
}

sub prefix_flush {
  for ($size = 0; $size < $prefix_size; $size++) {
    $cmd = "flush_prefix pname$size"; $rst = "OK";
    mem_cmd_is($sock, $cmd, "", $rst);
  }
}

sub item_get_miss {
  for ($size = 0; $size < $prefix_size; $size++) {
    $cmd = "get pname$size:foo";
    $rst = "END";
    mem_cmd_is($sock, $cmd, "", $rst);
  }
}

sub count_prefix_empty {
  print $sock "stats detail dump\r\n";
  my $line = scalar <$sock>;
  $count = 0;
  while ($line =~ /^PREFIX/) {
    $count = $count + 1;
    $line = scalar <$sock>;
  }
  if ($count != 0)
  {
    croak("The number of prefixes is incorrect.");
  }
}

$cmd = "stats detail on"; $rst = "OK";
mem_cmd_is($sock, $cmd, "", $rst);
prefix_insert();
count_prefix_exist();
item_get_hit();
prefix_flush();
count_prefix_empty();
item_get_miss();

# after test
release_memcached($engine, $server);
