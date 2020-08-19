use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

use GLib::Roles::Pointers;

unit package GLib::Compat::Definitions;

our constant sa_family_t is export := guint32;
# cw: Need definition for sa_family_t

class sockaddr is repr<CStruct> is export does GLib::Roles::Pointers {
    has sa_family_t  $.sa_family is rw;   #= address family
    has Str          $!sa_data;           #= socket address (variable-length data)

    method sa_data is rw {
      Proxy.new:
        FETCH => -> $           { $!sa_data },
        STORE => -> $, Str() \s { $!sa_data := s };
    }
}
