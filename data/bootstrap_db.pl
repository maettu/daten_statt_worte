#!/usr/bin/perl
use Modern::Perl;

# this script bootstraps the needed sqlite3 db.
# to run, it requires the following xlsx files:
# - Situationen.xlsx
#       - with 5 sheets for the colors / trips
# - Reaktionen
# - Erleuchtungen
# The texts just need to be placed into column A, one per line

use Spreadsheet::Read;
use DBI;
use DBD::SQLite;
my $dbh;

# check all xlsx files present

my @files = ('./import_files/Situationen.xlsx', './import_files/Reaktionen.xlsx', './import_files/Erleuchtungen - Fähigkeiten.xlsx');

for (@files){
    die unless -f $_;
}

if (-f './schicksack.db'){
    say "using existing database file schicksack.db";

    # XXX check if needed tables and data are present
    # atm do not implement.
    say "merging data into existing DB not implemented.";
    say "Move DB file away to make a new one.";
#~     exit;
    `rm schicksack.db`;

}
if (! -f './schicksack.db') {
    say "making new database in file schicksack.db";
    $dbh = DBI->connect("dbi:SQLite:dbname=./schicksack.db","","")
        or die $!;

    # XXX create database tables
    my @stmts = (
        'trips (id integer auto_increment not null, name text, color text)',
        'reactions (id integer auto_increment_not null, text text);',
        'enlightenment (id integer auto_increment not null, text text);',
        'situations (id integer auto_increment not null, text text, trip integer, foreign key(trip) references trips(id));'
    );
    for (@stmts){
        my $sth = $dbh->prepare("CREATE TABLE $_");
        $sth->execute;
    }

    # XXX insert infrasctructure data: trips
    @stmts = (
        " 1 , 'Der Weg in die Gesellschaft'  , 'gelb'   " ,
        " 2 , 'Partner-Trip'                 , 'orange' " ,
        " 3 , 'Polit-Trip'                   , 'rot'    " ,
        " 4 , 'Schöner Wohnen & Fahren-Trip' , 'grün'   " ,
        " 5 , 'Selbstfindungs-& Mystik-Trip' , 'blau'   "
    );

    for (@stmts){
        my $sth = $dbh->prepare("INSERT INTO trips VALUES ($_)");
        $sth->execute;
    }
}



# insert data

# load situations
# sheet order is: yellow, orange, red, green, blue
my $c = 0;
# sheet_num is magically equivalent to the foreign key to "trips" :-)
my $sheet_num = -1;
for my $sheet (@{ReadData $files[0]}){
    $sheet_num++;
    # in Spreadsheet::Read, sheet 0 is the controla structure: skip this
    next if $sheet_num==0;
    say $sheet->{label};
    for (1 .. $sheet->{maxrow}){
        my $cell = $sheet->{"A$_"};
        next unless $cell;

        # for the moment, just ignore "Neuerfindungen:" and load
        # everything.
        next if $cell =~ /^\s*Neuerfindungen\s*:\s*$/;
        $c++;
        my $sth = $dbh->prepare(
            "INSERT INTO situations values ($c, '$cell', $sheet_num)"
        );
        $sth->execute;
        say $cell;
    }
}

# load reactions
{
    $c = 0;
    my $sheet = ReadData($files[1])->[1];
    for (1 .. $sheet->{maxrow}){
        my $cell = $sheet->{"A$_"};
        next unless $cell;
        next if $cell =~ /^\s*Neuerfindungen\s*:\s*$/;
        $c++;
        my $sth = $dbh->prepare(
            "INSERT INTO reactions values ($c, '$cell')"
        );
        $sth->execute;
        say $cell;
    }
}


# load enlightenment
{
    my $c = 0;
    my $sheet = ReadData($files[2])->[1];

    for (1 .. $sheet->{maxrow}){
        my $cell = $sheet->{"A$_"};
        next unless $cell;
        next if $cell =~ /^\s*Neuerfindungen\s*:\s*$/;
        $c++;
        my $sth = $dbh->prepare(
            "INSERT INTO enlightenment values ($c, '$cell')"
        );
        $sth->execute;
        say $cell;
    }
}

