use v6;

use lib <. t>;
use NativeCall;
use Test;

use GLib::Roles::TypedBuffer;

class CStructTest is repr<CStruct> {
  has int32 $.a;
  has int32 $.b;
  has num32 $.c;
  has num64 $.d;
  has Str   $.e;
}

sub getStructArray()
  returns Pointer
  is native('t/01-typed-buffer.so')
{ * }

plan 25;

my $sal = GLib::Roles::TypedBuffer[CStructTest].new-typedbuffer-obj( getStructArray() );
my $num = $sal.elems;

is $num, 5, 'Typed Buffer detects the correct number of elements';

for $sal.Array.kv -> $k, $v {
  is        $v.a, $k,           "Element $k .a member has the proper value";
  is        $v.b, $k + 1,       "Element $k .b member has the proper value";
  is-approx $v.c, 22 / 7 * $k , "Element $k .c member has the proper value";
  is-approx $v.d, 22 / 7 / $k , "Element $k .d member has the proper value" if $k;
  is $v.e,       "Hello $k",    "Element $k .e member has the proper value";
}
