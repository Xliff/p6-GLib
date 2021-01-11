use v6.c;

use GLib::Raw::Subs;

role GLib::Roles::TypedArray[::T, $raw, ::O = Mu] {
  
  method Array {
    my @a;

    die 'Cannot be unraw with unspecified object type!' if $raw && O =:= Mu;

    for ^self.elems {
      say self[$_].^name;
      @a[$_] = cast(T, self[$_]);
      @a[$_] = O.new( @a[$_] ) unless $raw;
    }
    @a;
  }

}
