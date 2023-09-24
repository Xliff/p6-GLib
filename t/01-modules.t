use v6.c;

use JSON::Fast;
use Test;

my $dist = from-json( "META6.json".IO.slurp );
my $mods = $dist<provides>;

plan $mods.elems;

for $mods.keys {
	my $m = try require ::("$_");

	ok $m !=:= Nil, "$_";
}
