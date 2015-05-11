#!/usr/bin/perl
use Modern::Perl;

package Helpers;

sub convert_umlauts{
    my $text = shift;

    my %conv = (
        'ä' => '&auml;',
        'ö' => '&ouml;',
        'ü' => '&uuml;',
        'Ä' => '&Auml;',
        'Ö' => '&Ouml;',
        'Ü' => '&Uuml;',
    );

    for (keys %conv){
        say $_;
        $text =~ s/$_/$conv{$_}/g;
    }
    say $text;
    return $text;
}

1;
