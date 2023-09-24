use v6.c;

use GLib::HashTable;

my $hash = GLib::HashTable::String.new;

$hash<Jazzy>      = 'Cheese';
$hash{'Mr Darcy'} = 'Treats';

say "There are { $hash.size } keys in the hash table";

say "Jazzy likes { $hash<Jazzy> }";
say "Mr Darcy gives out { $hash{'Mr Darcy'} }";

say $hash.get-keys;
say $hash.get-values;
say $hash.pairs;
