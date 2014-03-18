#!/usr/bin/perl

use DBI;
use Data::Dumper;
use strict;
#use diagnostics;

my $filename = '>/var/www/serikov/data/www/backups/beta.redmine.fablab61.ru/beta_'.mysql_now().'.meta.txt';
my $db = "ru_fablab61_redmine_beta";

sub sql_server_connect {
	my $host = "localhost"; my $port = "3306"; my $user = "test"; my $pass = "0000";
	my $dbh = DBI->connect("DBI:mysql:$db:$host:$port",$user,$pass);
	return $dbh;
}

have_id_and_created();


sub mysql_now() {
        my($sec,$min,$hour,$mday,$mon,$year,$wday, $yday,$isdst)=localtime(time);
        my($result)=sprintf("%4d%02d%02d_%02d%02d%02d",$year+1900,$mon+1,$mday,$hour,$min,$sec);
        return $result;
}

sub have_id_and_created {
	open FILE, $filename;
	my $target_cols = [ qw/id created_on date/ ];
	my $plugin_tables = [ qw/contacts contacts_deals/ ];
	my $dbh = sql_server_connect();
	my $hash = {};
	my $i;
	my @tables = $dbh->tables;
	for (@tables) {
		my ($db, $table) =  split '\.', $_ ;
		#$db =~ s/\`//g;
		#$table =~ s/\`//g;
		my $arr_ref = $dbh->selectcol_arrayref("desc $table");
		my $a=[];
		for (@$arr_ref){
			if ($_ ~~ @$target_cols ) {
				push (@$a, $_);
			}
			#
			# warn $items;
			# push @{$hash->{$table}},  $_  if ( $_ ~~ @$target_cols );
			# push @ {$hash->{$table}},  { $_  => $_ ~~ @$target_cols ? 1 : 0 } if ( $_ ~~ @$target_cols );	#smart matching

		}
		
		my $sql="";
		if (@$a) {

			$i++; 
			my $sql = "select ".join (', ', @$a)." from ".$table." order by id desc";
			#my $sql = "select * from ".$table;
			#warn $sql;
			my $hash_ref = $dbh->selectrow_hashref("$sql");
			#warn Dumper $hash_ref;
			my $table1 = $table;
			#if ($hash_ref->{'created_on'}) { my $id = $hash_ref->{'created_on'} };
			#if ($hash_ref->{'id'}) { my $date = $hash_ref->{'created_on'} };
			print FILE $table1. " | ".$hash_ref->{'id'}." | ".$hash_ref->{'created_on'}."\n";
		}


		
		#warn Dumper @$a;
	}

	print FILE "Total count of tables: ".scalar (@tables)."\n";	
	print FILE "Total count of target tables: ".$i."\n";	


	 # warn Dumper $hash; # not sorted

	 # for my $key ( keys %$hash ) {
	 # 	$hash->{$key};
 	# 	print "key: $key, $hash->{$key}   \n";
	 # }

	#return $hash;
	close $filename;
}
