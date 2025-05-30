use v6.c;

use Method::Also;
use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Bytes;

use GLib::Roles::Implementor;

class GLib::Bytes {
  also does GLib::Roles::Implementor;

  has GBytes $!b is implementor handles<p>;

  submethod BUILD (GBytes :$bytes) {
    $!b = $_ with $bytes;
  }

  # method Str {
  #   self.get_data.head;
  # }

  method GLib::Raw::Definitions::GBytes
    is also<GBytes>
  { $!b }

  multi method new (GBytes $bytes, :$ref) {
    $bytes ?? self.bless( :$bytes ) !! Nil;
  }

  multi method new (Str $data, :$encoding = 'utf8') {
    samewith( $data.encode($encoding) );
  }
  multi method new (Blob $data) {
    samewith( CArray[uint8].new($data), $data.bytes );
  }
  multi method new (CArray[uint8] $data, Int() $size) {
    my gsize $s = $size;

    self.bless( bytes => g_bytes_new($data, $s) );
  }

  method new_from_bytes (GBytes() $bytes, Int() $offset, Int() $length)
    is also<new-from-bytes>
  {
    my gsize ($o, $l) = ($offset, $length);

    self.bless( bytes => g_bytes_new_from_bytes($bytes, $o, $l) );
  }

  method new_static (gpointer $data, Int() $size) is also<new-static> {
    my gsize $s = $size;

    self.bless( bytes => g_bytes_new_static($data, $s) );
  }

  method new_take (gpointer $data, Int() $size) is also<new-take> {
    my gsize $s = $size;

    self.bless( bytes => g_bytes_new_take($data, $s) );
  }

  method new_with_free_func (
    gpointer $data,
    Int()    $size,
             &free_func = %DEFAULT-CALLBACKS<GDestroyNotify>,
    gpointer $user_data = gpointer
  )
    is also<new-with-free-func>
  {
    my gsize $s = $size;

    self.bless(
      bytes => g_bytes_new_with_free_func($data, $s, &free_func, $user_data)
    );
  }

  method compare (GBytes() $bytes2) {
    g_bytes_compare($!b, $bytes2);
  }

  method equal (GBytes() $bytes2) {
    g_bytes_equal($!b, $bytes2);
  }

  proto method get_data (|)
    is also<get-data>
  { * }


  method Buf  { $.get_data( :!all ) }
  method Blob { $.Buf.Blob          }

  multi method get_data ( :$all = True ){
    samewith($, :$all);
  }
  multi method get_data (
     $size      is rw,
    :$all              = False,
    :$buf              = True,
    :$raw              = False,
    :$encoding         = 'utf8'
  ) {
    my gsize $s = 0;

    my $d = g_bytes_get_data($!b, $s);
    $size = $s;
    unless $raw {
      $d = Buf[uint8].new( $d[^$size] );
      return $d if $buf;
      $d.decode($encoding);
    }
    $all.not ?? $d !! ($d, $size);
  }

  method get_size is also<get-size> {
    g_bytes_get_size($!b);
  }

  method get_type {
    state ($n, $t);

    unstable_get_type( self.^name, &g_bytes_get_type, $n, $t );
  }

  method hash {
    g_bytes_hash($!b);
  }

  method ref is also<upref> {
    g_bytes_ref($!b);
    self;
  }

  method unref is also<downref> {
    g_bytes_unref($!b);
  }

  method unref_to_array (:$raw = False) is also<unref-to-array> {
    my $ba = g_bytes_unref_to_array($!b);

    $ba ??
      ( $raw ?? $ba !! GLib::BytesArray.new($ba, :!ref) )
      !!
      Nil;
  }

  method unref_to_data (Int() $size) is also<unref-to-data> {
    my gsize $s = $size;

    g_bytes_unref_to_data($!b, $s);
  }

}
