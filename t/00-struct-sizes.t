use v6.c;

use Test;
use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Subs;

use lib <scripts ../scripts>;

use GTKScripts;

parse-file($CONFIG-NAME);

#require ::($_ = "GLib::Raw::Structs");
my $prefix  = %config<prefix>.subst('::', '');
my $cu      = "{ $prefix }::Raw::Structs";
try require ::($cu);

#$cu ~= '::EXPORT::DEFAULT';
my @classes =
  ::("$cu").WHO
           .keys
           .grep({
             .defined
             &&
             .starts-with(%config<struct-prefix> // $prefix)
            })
           .sort;
@classes.push: (%config<extra-test-classes> // '').split(',');

plan 65;

for @classes {
  sub sizeof () returns int64 { ... }
  trait_mod:<is>( &sizeof, :native('t/00-struct-sizes.so') );
  trait_mod:<is>( &sizeof, :symbol('sizeof_' ~ $_) );

  next unless .chars;

  my $c = ::("{ $cu }::$_");

  #say "In loop for ('{ $_ } / { $c.HOW } / { $c.REPR }')...";

  next unless $c.HOW ~~ Metamodel::ClassHOW;
  next unless $c.REPR eq 'CStruct';

  #diag $_;
  if
    ($c.WHY.leading // '') ~~ / ['Opaque' | 'Skip Struct'] [':' (.+) ]? $$ /
    ||
    $c ~~ StructSkipsTest
  {
    my $pass-msg = "Structure '{ $_ }' is not to be tested";
    if $c ~~ StructSkipsTest {
      $pass-msg ~= " ({ $c.reason })";
    } else {
      $pass-msg ~= " ({ $/[0] })" if $/[0]
    }

    pass $pass-msg;
    next;
  }
  is nativesizeof($c), sizeof(), "Structure sizes for { $_ } match";
}

# cw: Use for generic struct size debugging.
#
# for <gsize GstMapFlags GHookList> {
#   sub sizeof () returns int64 { ... }
#   trait_mod:<is>( &sizeof, :native('t/00-struct-sizes.so') );
#   trait_mod:<is>( &sizeof, :symbol('sizeof_' ~ $_) );
#
#   diag sizeof();
# }
