#!/usr/bin/perl -w

use strict;
use warnings;
use v5.10.1;
use utf8;
use Test::More tests => 38;
use Test::NoWarnings;
use Test::Exception;

BEGIN { require_ok 'App::Sqitch::Plan::NodeList' or die }

my $foo = ['foo'];
my $bar = ['bar'];
my $baz = ['baz'];
my $yo1 = ['yo'];
my $yo2 = ['yo'];
my $alpha = ['@alpha'];

my $nodes = App::Sqitch::Plan::NodeList->new(
    foo => $foo,
    bar => $bar,
    yo  => $yo1,
    '@alpha' => $alpha,
    baz => $baz,
    yo  => $yo2,
);

is $nodes->count, 6, 'Count should be six';
is_deeply [$nodes->nodes], [$foo, $bar, $yo1, $alpha, $baz, $yo2],
    'Nodes should be in order';
is $nodes->node_at(0), $foo, 'Should have foo at 0';
is $nodes->node_at(1), $bar, 'Should have bar at 1';
is $nodes->node_at(2), $yo1, 'Should have yo1 at 2';
is $nodes->node_at(3), $alpha, 'Should have @alpha at 3';
is $nodes->node_at(4), $baz, 'Should have baz at 4';
is $nodes->node_at(5), $yo2, 'Should have yo2 at 5';

is $nodes->index_of('non'), undef, 'Should not find "non"';
is $nodes->index_of('foo'), 0, 'Should find foo at 0';
is $nodes->index_of('bar'), 1, 'Should find bar at 1';
is $nodes->index_of('@alpha'), 3, 'Should find @alpha at 3';
is $nodes->index_of('baz'), 4, 'Should find baz at 4';

throws_ok { $nodes->index_of('yo') } qr/^\QKey "yo" at multiple indexes/,
    'Should get error looking for index of "yo"';

throws_ok { $nodes->index_of('yo', '@howdy') } qr/^Unknown tag: "\@howdy"/,
    'Should get error looking for invalid tag';

is $nodes->index_of('yo', '@alpha'), 2, 'Should get 2 for yo@alpha';
is $nodes->index_of('yo', '@HEAD'), 5, 'Should get 5 for yo@HEAD';
is $nodes->index_of('foo', '@alpha'), 0, 'Should get 0 for foo@alpha';
is $nodes->index_of('foo', '@HEAD'), 0, 'Should get 0 for foo@HEAD';
is $nodes->index_of('baz', '@alpha'), undef, 'Should get undef for baz@alpha';
is $nodes->index_of('baz', '@HEAD'), 4, 'Should get 4 for baz@HEAD';

is $nodes->get('foo'), $foo, 'Should get foo for "foo"';
is $nodes->get('bar'), $bar, 'Should get bar for "bar"';
is $nodes->get('@alpha'), $alpha, 'Should get @alpha for "@alpha"';
is $nodes->get('baz'), $baz, 'Should get baz for "baz"';

is $nodes->get('yo', '@alpha'), $yo1, 'Should get yo1 for yo@alpha';
is $nodes->get('yo', '@HEAD'), $yo2, 'Should get yo2 for yo@HEAD';
is $nodes->get('foo', '@alpha'), $foo, 'Should get foo for foo@alpha';
is $nodes->get('foo', '@HEAD'), $foo, 'Should get foo for foo@HEAD';
is $nodes->get('baz', '@alpha'), undef, 'Should get undef for baz@alpha';
is $nodes->get('baz', '@HEAD'), $baz, 'Should get baz for baz@HEAD';

throws_ok { $nodes->get('yo') } qr/^\QKey "yo" at multiple indexes/,
    'Should get error looking for index of "yo"';

throws_ok { $nodes->get('yo', '@howdy') } qr/^Unknown tag: "\@howdy"/,
    'Should get error looking for invalid tag';

my $hi = ['hi'];
ok $nodes->append(hi => $hi), 'Push hi';
is $nodes->count, 7, 'Count should now be seven';
is_deeply [$nodes->nodes], [$foo, $bar, $yo1, $alpha, $baz, $yo2, $hi],
    'Nodes should be in order with $hi at the end';