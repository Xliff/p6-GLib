use v6.c;

use Test;
use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Structs;

plan 56;

#require ::($_ = "GLib::Raw::Structs");
my $cu      = 'GLib::Raw::Structs::EXPORT::DEFAULT';
my @classes = ::($cu).WHO
                     .keys
                     .grep( *.defined && *.starts-with('G') )
                     .sort;
@classes.push: 'tm';

for @classes {
  sub sizeof () returns int64 { ... }
  trait_mod:<is>( &sizeof, :native('t/00-struct-sizes.so') );
  trait_mod:<is>( &sizeof, :symbol('sizeof_' ~ $_) );

  my $c = ::("$_");
  next unless $c.HOW ~~ Metamodel::ClassHOW;
  next unless $c.REPR eq 'CStruct';

  #diag $_;
  if ($c.WHY.leading // '') eq ('Opaque', 'Skip Struct').any {
    pass "Structure '{ $_ }' is not to be tested";
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
