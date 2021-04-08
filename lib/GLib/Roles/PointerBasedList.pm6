use v6.c;

use GLib::Raw::Types;

use NativeCall;
use GLib::Raw::Subs;

role GLib::Roles::PointerBasedList {

  method addToList (
    $l,
    @list,
    :$signed   = False,
    :$double   = False,
    :$direct   = False,
    :$encoding = 'utf8',
    :$typed
  ) {
    my $firstElement = True;
    for @list -> $_ is copy {
      # Should be abstracted to a sub, toPointer()
      my $v = toPointer(
        $_,
        :$signed   = False,
        :$double   = False,
        :$direct   = False,
        :$encoding = 'utf8',
        :$typed
      );
      if $firstElement {
        $l.data       = $v;
        $firstElement = False;
      } else {
        $l.append($v);
      }
    }
  }

}
