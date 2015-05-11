#!/usr/bin/perl
use Modern::Perl;
use DBI;
use DBD::SQLite;
use Mojolicious::Lite;

my $dbh = DBI->connect("dbi:SQLite:dbname=../data/schicksack.db","","")
    or die $!;
my $sth = $dbh->prepare("SELECT * FROM trips");
$sth->execute;
my %trips;
while (my $row = $sth->fetch){
    $trips{$row->[0]}= [$row->[1],$row->[2]];
}
use Data::Dumper;say Dumper \%trips;

my $links_string;
for my $trip (sort keys %trips){
    $links_string .= "<p><a href=/?trip=$trip>$trips{$trip}[1]: $trips{$trip}[0]</a></p>";
}

get '/' => sub {
    my $c = shift;
    my $trip = $c->param('trip');
    my $situation_string = "";
    my $reaction_string = "";
    if ($trip){
        $situation_string = "<h2>Situation</h2>";
        $sth = $dbh->prepare(
            "SELECT * FROM situations WHERE trip=$trip order by RANDOM() LIMIT 1");
        $sth->execute;
        my $row = $sth->fetch;
        $situation_string.= $row->[1];

        $reaction_string = "<h2>Reaktion</h2>";
        $sth = $dbh->prepare(
            "SELECT * FROM reactions ORDER BY RANDOM() LIMIT 1"
        );
        $sth->execute;
        $row = $sth->fetch;
        say Dumper $row;
        $reaction_string .= $row->[1];
    }
    $c->render(
    header =>
    text => "<h1>Schicksack</h1>Daten statt Worte<br/><br/>Farbe? $links_string $situation_string $reaction_string"
    );
};

app-start;
