use v6.c;

use GLib::Raw::Types;

use NativeCall;
use GLib::Raw::Subs;

role GLib::Roles::PointerBasedList {

  method addToList (
    $l,
    @list,
    :$signed        = False,
    :$double        = False,
    :$direct        = False,
    :$encoding      = 'utf8',
    :type(:$typed)
  ) {
    my $firstElement = True;
    for @list -> $_ is copy {
      my $v = toPointer(
        $_,
        :$signed,
        :$double,
        :$direct,
        :$encoding,
        :$typed
      );
      say "atl - V: { $v }" if checkDEBUG(2);
      if $firstElement {
        $l.data       = $v;
        $firstElement = False;
      } else {
        $l.append($v);
      }
    }
  }

}
