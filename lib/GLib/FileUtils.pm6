use v6.c;

use Method::Also;

use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Types;
use GLib::Raw::FileUtils;

use GLib::Roles::StaticClass;

class GLib::FileUtils {
  also does GLib::Roles::StaticClass;

  multi method basename (IO::Path $path) {
    $path.basename;
  }
  multi method basename (Str() $file_name) {
    g_basename($file_name);
  }

  proto method build_filename (|)
      is also<build-filename>
  { * }

  multi method build_filename (*@args) {
    samewith(@args);
  }
  multi method build_filename (@args) {
    self.build_filenamev( resolve-gstrv(@args) )
  }
  method build_filenamev (CArray[Str] $args) is also<build-filenamev> {
    g_build_filenamev($args);
  }

  proto method build_path (|)
      is also<build-path>
  { * }

  multi method build_path (*@args) {
    samewith(@args);
  }
  multi method build_path (@args) {
    self.build_pathv($*SPEC.dir-sep, @args);
  }

  proto method build_pathv (|)
      is also<build-pathv>
  { * }

  multi method build_pathv (Str() $separator, @args) {
    samewith( $separator, resolve-gstrv(@args) );
  }
  multi method build_pathv (Str() $separator, CArray[Str] $args) {
    g_build_pathv($separator, $args);
  }

  method canonicalize_filename (Str() $filename, Str() $relative_to)
    is also<canonicalize-filename>
  {
    g_canonicalize_filename($filename, $relative_to);
  }

  method dir_make_tmp (Str() $tmpl, CArray[Pointer[GError]] $error = gerror)
    is also<dir-make-tmp>
  {
    clear_error;
    my $td = g_dir_make_tmp($tmpl, $error);
    set_error($error);
    $td;
  }

  method error_from_errno (Int() $err_no) is also<error-from-errno> {
    my gint $e = $err_no;
    g_file_error_from_errno($e);
  }

  method error_quark is also<error-quark> {
    g_file_error_quark();
  }

  proto method get_contents (|)
    is also<get-contents>
  { * }

  multi method get_contents (IO::Path $path) {
    my $rv = samewith($path.absolute, $, $, :all);

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method get_contents (
    Str()                   $filename,
    CArray[Pointer[GError]] $error    =  gerror,
    :$all = False
  ) {
    (my $c = CArray[Str].new)[0] = Str;

    my $rv = samewith($filename, $c, $, $error, :all);

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method get_contents (
    Str()                   $filename,
    CArray[Str]             $contents,
                            $length    is rw,
    CArray[Pointer[GError]] $error     =  gerror,
                            :$all      =  False
  ) {
    my gsize $l = 0;

    clear_error;
    my $rv = g_file_get_contents($filename, $contents, $l, $error);
    set_error($error);

    $length = $l;
    $all.not ?? $rv !! ( $rv, ppr($contents) );
  }

  method open_tmp (
    Str()                   $tmpl,
    Str()                   $name_used,
    CArray[Pointer[GError]] $error      = gerror
  )
    is also<open-tmp>
  {
    clear_error;
    my $fd = g_file_open_tmp($tmpl, $name_used, $error);
    set_error($error);
    $fd
  }

  proto method read_link (|)
    is also<file-read-link>
  { * }

  multi method read_link (
    IO::Path                $path,
    CArray[Pointer[GError]] $error = gerror
  ) {
    samewith($path.absolute, $error);
  }
  multi method read_link (
    Str()                   $filename,
    CArray[Pointer[GError]] $error     = gerror
  ) {
    clear_error;
    my $l = g_file_read_link($filename, $error);
    set_error($error);
    $l
  }

  proto method set_contents (|)
    is also<set-contents>
  { * }

  multi method set_contents (
    IO::Path                $path,
    Str()                   $contents,
    Int()                   $length    = -1,
    CArray[Pointer[GError]] $error     = gerror
  ) {
    samewith($path.absolute, $contents, $length, $error);
  }
  multi method set_contents (
    Str()                   $filename,
    Str()                   $contents,
    Int()                   $length    = -1,
    CArray[Pointer[GError]] $error     = gerror
  ) {
    my gssize $l = $length;

    clear_error;
    my $rv = so g_file_set_contents($filename, $contents, $length, $error);
    set_error($error);
    $rv;
  }

  proto method test (|)
    is also<file-test>
  { * }

  multi method test (IO::Path $path, Int() $test) {
    samewith($path, $test);
  }
  multi method test (Str() $filename, Int() $test) {
    my GFileTest $t = $test;

    so g_file_test($filename, $t);
  }

  method get_current_dir is also<get-current-dir> {
    g_get_current_dir();
  }

  proto method mkdir_with_parents (|)
    is also<mkdir-with-parents>
  { * }

  multi method mkdir_with_parents (IO::Path $pathname, Int() $mode) {
    samewith($pathname.absolute, $mode);
  }
  multi method mkdir_with_parents (Str() $pathname, Int() $mode) {
    my gint $m = $mode;

    g_mkdir_with_parents($pathname, $m);
  }

  method mkdtemp (Str() $tmpl) {
    g_mkdtemp($tmpl);
  }

  method mkdtemp_full (Str() $tmpl, Int() $mode) is also<mkdtemp-full> {
    my gint $m = $mode;

    g_mkdtemp_full($tmpl, $m);
  }

  method mkstemp (Str $tmpl is rw) {
    my $fn = CArray[uint8].new( $tmpl.comb.map(*.ord) );
    $fn[$tmpl.chars] = 0;

    my $rv = g_mkstemp($fn);
    $tmpl = CArrayToArray($fn, $tmpl.chars).map( *.chr ).join('');
    $rv;
  }

  method mkstemp_full (Str() $tmpl, Int() $flags, Int() $mode)
    is also<mkstemp-full>
  {
    my gint ($f, $m) = ($flags, $mode);

    g_mkstemp_full($tmpl, $f, $m);
  }

  method get_basename (Str() $file_name) is also<get-basename> {
    g_path_get_basename($file_name);
  }

  method get_dirname (Str() $file_name) is also<get-dirname> {
    g_path_get_dirname($file_name);
  }

  method is_absolute (Str() $file_name) is also<is-absolute> {
    so g_path_is_absolute($file_name);
  }

  method skip_root (Str() $file_name) is also<skip-root> {
    g_path_skip_root($file_name);
  }

  multi method access (IO::Path $path, Int() $mode) {
    samewith($path.absolute);
  }
  multi method access (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_access($filename, $m);
  }

  multi method chdir (IO::Path $path) {
    samewith($path.absolute);
  }
  multi method chdir (Str() $path) {
    g_chdir($path);
  }

  multi method chmod (IO::Path $path, Int() $mode) {
    samewith($path.absolute, $mode);
  }
  multi method chmod (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_chmod($filename, $m);
  }

  method close (Int() $fd, CArray[Pointer[GError]] $error = gerror) {
    my gint $f = $fd;

    clear_error;
    my $rv = so g_close($f, $error);
    set_error($error);
    $rv
  }

  multi method creat (IO::Path $path, Int() $mode) {
    samewith($path.absolute, $mode);
  }
  multi method creat (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_creat($filename, $m);
  }

  multi method fopen (IO::Path $path, Str() $mode) {
    samewith($path.absolute, $mode);
  }
  multi method fopen (Str() $filename, Str() $mode) {
    my gint $m = $mode;

    g_fopen($filename, $m);
  }

  multi method freopen (IO::Path $path, Str() $mode, FILE $stream) {
    samewith($path.absolute, $mode, $stream);
  }
  multi method freopen (Str() $filename, Str() $mode, FILE $stream) {
    # cw: String version of MODE
    g_freopen($filename, $mode, $stream);
  }

  method fsync (Int() $fd) {
    my gint $f = $fd;

    g_fsync($f);
  }

  multi method lstat (IO::Path $path, GStatBuf $buf) {
    samewith($path.absolute, $buf);
  }
  multi method lstat (Str() $filename, GStatBuf $buf) {
    g_lstat($filename, $buf);
  }

  multi method mkdir (IO::Path $path, Int() $mode) {
    samewith($path.absolute, $mode);
  }
  multi method mkdir (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_mkdir($filename, $m);
  }

  multi method open (IO::Path $path, Int() $flags, Int() $mode) {
    samewith($path.absolute, $flags, $mode);
  }
  multi method open (Str() $filename, Int() $flags, Int() $mode) {
    my gint ($f, $m) = ($flags, $mode);

    g_open($filename, $f, $m);
  }

  multi method remove (IO::Path $path) {
    samewith($path.absolute);
  }
  multi method remove (Str() $filename) {
    g_remove($filename);
  }

  multi method rename (IO::Path $oldfilename, IO::Path $newfilename) {
    samewith($oldfilename.absolute, $newfilename.absolute);
  }
  multi method rename (Str() $oldfilename, Str() $newfilename) {
    g_rename($oldfilename, $newfilename);
  }

  multi method rmdir (IO::Path $path) {
    samewith($path.absolute);
  }
  multi method rmdir (Str() $filename) {
    g_rmdir($filename);
  }

  multi method stat (IO::Path $path, GStatBuf $buf) {
    samewith($path.absolute, $buf);
  }
  multi method stat (Str() $filename, GStatBuf $buf) {
    g_stat($filename, $buf);
  }

  multi method unlink (IO::Path $path) {
    samewith($path.absolute);
  }
  multi method unlink (Str() $filename) {
    g_unlink($filename);
  }

  method write (Int() $fd, Str() $text, Int() $length) {
    my size_t $l = $length;

    # Make the native definition.
    sub write (guint, Str, size_t) returns guint32 is native { * }

    # Then use it.
    write($fd, $text, $l);
  }

}
