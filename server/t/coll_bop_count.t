#!/usr/bin/perl

use strict;
use Test::More tests => 20;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

=head
get bkey1: END
get bkey2: END
bop insert bkey1 90 0x0001 6 create 11 0 0 datum9: CREATED_STORED
bop insert bkey1 70 0x0001 6 datum7: STORED
bop insert bkey1 50 0x0010 6 datum5: STORED
bop insert bkey1 30 0x0011 6 datum3: STORED
bop insert bkey1 10 0x0110 6 datum1: STORED
bop create bkey2 11 0 0: CREATED
bop count bkey1 10..90: COUNT=5
bop count bkey1 60..20: COUNT=2
bop count bkey1 15..25: COUNT=0
bop count bkey1 25..15: COUNT=0
bop count bkey1 10..90 0 EQ 0x0001: COUNT=2
bop count bkey1 10..90 0 EQ 0x0010: COUNT=1
bop count bkey1 10..90 0 NE 0x0001,0x0010: COUNT=2
bop count bkey2 10..90: COUNT=0
delete bkey1: DELETED
delete bkey2: DELETED
=cut

my $engine = shift;
my $server = get_memcached($engine);
my $sock = $server->sock;

my $cmd;
my $val;
my $rst;

$cmd = "get bkey1"; $rst = "END";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "get bkey2"; $rst = "END";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop insert bkey1 90 0x0001 6 create 11 0 0"; $val = "datum9"; $rst = "CREATED_STORED";
mem_cmd_is($sock, $cmd, $val, $rst);
$cmd = "bop insert bkey1 70 0x0001 6"; $val = "datum7"; $rst = "STORED";
mem_cmd_is($sock, $cmd, $val, $rst);
$cmd = "bop insert bkey1 50 0x0010 6"; $val = "datum5"; $rst = "STORED";
mem_cmd_is($sock, $cmd, $val, $rst);
$cmd = "bop insert bkey1 30 0x0011 6"; $val = "datum3"; $rst = "STORED";
mem_cmd_is($sock, $cmd, $val, $rst);
$cmd = "bop insert bkey1 10 0x0110 6"; $val = "datum1"; $rst = "STORED";
mem_cmd_is($sock, $cmd, $val, $rst);
$cmd = "bop create bkey2 11 0 0"; $rst = "CREATED";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90"; $rst = "COUNT=5";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 60..20"; $rst = "COUNT=2";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 15..25"; $rst = "COUNT=0";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 25..15"; $rst = "COUNT=0";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90 0 EQ 0x0001"; $rst = "COUNT=2";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90 0 EQ 0x0010"; $rst = "COUNT=1";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90 0 EQ 0x0010,0x0001"; $rst = "COUNT=3";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90 0 EQ 0x0010,0x0001,0x0011"; $rst = "COUNT=4";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey1 10..90 0 NE 0x0001,0x0010"; $rst = "COUNT=2";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "bop count bkey2 10..90"; $rst = "COUNT=0";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "delete bkey1"; $rst = "DELETED";
mem_cmd_is($sock, $cmd, "", $rst);
$cmd = "delete bkey2"; $rst = "DELETED";
mem_cmd_is($sock, $cmd, "", $rst);

# after test
release_memcached($engine, $server);
