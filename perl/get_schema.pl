#!/usr/bin/perl

use DBI;
use Data::Dumper;
use strict;

if ($#ARGV == -1) { 
	print "ARGV = $#ARGV. No input database.yml file specified\n";
	exit 1 
}

print "Target database file is @ARGV[0]\n";

my $filename = '>meta.txt';
my $config = @ARGV[0];

##### Read config ######
open FILE, $config or die $!;
my $db = ""; 
my $host = "";
my $user = "";
my $pass = "";
my $sql_port = "3306"; 
while (<FILE>) {
  $db = $1 if ($_ =~ /database: (\w+)/);
  $host = $1 if ($_ =~ /host: (\w+)/);
  $user = $1 if ($_ =~ /username: (\w+)/);
  $pass = $1 if ($_ =~ /password: "(\w+)"/);

}
close $config;
##### End of read config ######

open FILE, $filename;
print FILE "# Meta info about columns:\n";
my $dbh = DBI->connect("DBI:mysql:$db:$host:$sql_port",$user,$pass);
my $tables = {};
my @tables = $dbh->tables;
my $hash={};
for (@tables) {
	my ($db, $table) =  split '\.', $_ ;
	$table =~ s/\`//g;
	my $col_names = "";
	$col_names = $dbh->selectcol_arrayref( qq{describe $_} );
	$hash->{$table} = scalar @$col_names;
}

#warn Dumper $hash;
$dbh->disconnect();

for my $i (sort keys %$hash) {
    print FILE "$i: $hash->{$i}\n";
}

print FILE "Total count of tables: ".scalar (@tables)."\n";	
close $filename;
