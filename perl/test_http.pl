#!/usr/bin/perl

use strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new();

if ( $#ARGV == 0 ) {
	my $domain = 'http://beta.redmine.fablab61.ru';
} else {
	my $domain = $ARGV[0];
}

$t->get_ok("$domain")->status_is(200);
$t->get_ok("$domain/login")->status_is(200);
$t->get_ok("$domain/my/page")->status_is(200);
$t->get_ok("$domain/projects")->status_is(200);
$t->get_ok("$domain/account/register")->status_is(200);
$t->get_ok("$domain/account/lost_password")->status_is(200);
$t->get_ok("$domain/projects/fablab/settings")->status_is(200);
$t->get_ok("$domain/projects/search?q=test")->status_is(200);
