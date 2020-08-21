use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::MappedFile;

use GLib::Bytes;

class GLib::MappedFile {
  has GMappedFile $!mf;

  submethod BUILD (:$mapped) {
    $!mf = $mapped if $mapped;
  }

  method GLib::Raw::Definitions::GMappedFile
    is also<GMappedFile>
  { $!mf }

  multi method new (GMappedFile $mapped) {
    $mapped ?? self.bless( :$mapped ) !! Nil;
  }
  multi method new (
    Str() $filename,
    Int() $writable,
    CArray[Pointer[GError]] $error
  ) {
    my gboolean $w = $writable.so.Int;

    clear_error;
    my $mapped = g_mapped_file_new($filename, $w, $error);
    set_error($error);

    $mapped ?? self.bless( :$mapped ) !! Nil;
  }

  method new_from_fd (
    Int() $fd,
    Int() $writable,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<new-from-fd>
  {
    my gint $f = $fd;
    my gboolean $w = $writable.so.Int;

    clear_error;
    my $mapped = g_mapped_file_new_from_fd($f, $w, $error);
    set_error($error);

    $mapped ?? self.bless( :$mapped ) !! Nil;
  }

  method free is DEPRECATED<unref> {
    g_mapped_file_free($!mf);
  }

  method get_bytes (:$raw = False)
    is also<
      get-bytes
      bytes
    >
  {
    my $b = g_mapped_file_get_bytes($!mf);

    $b ??
      ( $raw ?? $b !! GLib::Bytes.new($b) )
      !!
      Nil;
  }

  method get_contents
    is also<
      get-contents
      contents
    >
  {
    g_mapped_file_get_contents($!mf);
  }

  method get_length
    is also<
      get-length
      length
    >
  {
    g_mapped_file_get_length($!mf);
  }

  method ref {
    g_mapped_file_ref($!mf);
    self;
  }

  method unref {
    g_mapped_file_unref($!mf);
  }

  # cw: This will probably need to be done for EVERY GLIB-BASED OBJECT.
  #     so that consumers will not need to deal with ::Raw compunits.
  method dnotify (GLib::MappedFile:U: ) {
    &g_mapped_file_unref
  }

}
