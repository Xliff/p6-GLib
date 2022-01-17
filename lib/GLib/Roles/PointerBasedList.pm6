use v6.c;

use GLib::Raw::Subs;

use NativeCall;

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
    for @list {
      # Should be abstracted to a sub, toPointer()

      #say "A: { .gist }";

      my $v = toPointer(
        $_,
        :$signed,
        :$double,
        :$direct,
        :$encoding,
        :$typed
      );

      #say "tpV: { $v.gist }";

      if $firstElement {
        $l.data       = $v;
        $firstElement = False;
      } else {
        $l.append($v);
      }
    }
  }

}
