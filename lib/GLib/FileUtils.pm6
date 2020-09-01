use v6.c;

use NativeCall;

use GLib::Compat::Definitions;
use GLib::Raw::Types;
use GLib::Raw::FileUtils;

use GLib::Roles::StaticClass;

class GLib::FileUtils {
  also does GLib::Roles::StaticClass;

  method basename (Str() $file_name) {
    g_basename($file_name);
  }

  method build_filename (@args) {
    self.build_filenamev( resolve-gstrv(@args) )
  }
  method build_filenamev (CArray[Str] $args) {
    g_build_filenamev($args);
  }

  method build_path (@args) {
    self.build_pathv($*SPEC.dir-sep, @args);
  }

  proto method build_pathv (|)
  { * }

  multi method build_pathv (Str() $separator, @args) {
    samewith( $separator, resolve-gstrv(@args) );
  }
  multi method build_pathv (Str() $separator, CArray[Str] $args) {
    g_build_pathv($separator, $args);
  }

  method canonicalize_filename (Str() $filename, Str() $relative_to) {
    g_canonicalize_filename($filename, $relative_to);
  }

  method dir_make_tmp (Str() $tmpl, CArray[Pointer[GError]] $error = gerror) {
    clear_error;
    my $td = g_dir_make_tmp($tmpl, $error);
    set_error($error);
    $td;
  }

  method file_error_from_errno (Int() $err_no) {
    my gint $e = $err_no;
    g_file_error_from_errno($e);
  }

  method file_error_quark () {
    g_file_error_quark();
  }

  method file_get_contents (
    Str() $filename,
    Str() $contents,
    Int() $length,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gsize $l = $length;

    clear_error;
    my $c = g_file_get_contents($filename, $contents, $l, $error);
    set_error($error);
    $c;
  }

  method file_open_tmp (
    Str() $tmpl,
    Str() $name_used,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $fd = g_file_open_tmp($tmpl, $name_used, $error);
    set_error($error);
  }

  method file_read_link (
    Str() $filename,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $l = g_file_read_link($filename, $error);
    set_error($error);
    $l
  }

  method file_set_contents (
    Str() $filename,
    Str() $contents,
    Int() $length,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my gssize $l = $length;

    clear_error;
    my $rv = so g_file_set_contents($filename, $contents, $length, $error);
    set_error($error);
    $rv;
  }

  method file_test (Str() $filename, Int() $test) {
    my GFileTest $t = $test;

    so g_file_test($filename, $t);
  }

  method get_current_dir () {
    g_get_current_dir();
  }

  method mkdir_with_parents (Str() $pathname, Int() $mode) {
    my gint $m = $mode;

    g_mkdir_with_parents($pathname, $m);
  }

  method mkdtemp (Str() $tmpl) {
    g_mkdtemp($tmpl);
  }

  method mkdtemp_full (Str() $tmpl, Int() $mode) {
    my gint $m = $mode;

    g_mkdtemp_full($tmpl, $m);
  }

  method mkstemp (Str() $tmpl) {
    g_mkstemp($tmpl);
  }

  method mkstemp_full (Str() $tmpl, Int() $flags, Int() $mode) {
    my gint ($f, $m) = ($flags, $mode);

    g_mkstemp_full($tmpl, $f, $m);
  }

  method path_get_basename (Str() $file_name) {
    g_path_get_basename($file_name);
  }

  method path_get_dirname (Str() $file_name) {
    g_path_get_dirname($file_name);
  }

  method path_is_absolute (Str() $file_name) {
    so g_path_is_absolute($file_name);
  }

  method path_skip_root (Str() $file_name) {
    g_path_skip_root($file_name);
  }

  method access (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_access($filename, $m);
  }

  method chdir (Str() $path) {
    g_chdir($path);
  }

  method chmod (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_chmod($filename, $m);
  }

  method close (gint $fd, CArray[Pointer[GError]] $error = gerror) {
    my gint $f = $fd;

    clear_error;
    my $rv = so g_close($f, $error);
    set_error($error);
    $rv
  }

  method creat (Str() $filename, Int() $mode) {
    my gint $m = $mode;

    g_creat($filename, $m);
  }

  method fopen (Str() $filename, Str() $mode) {
    my gint $m = $mode;

    g_fopen($filename, $m);
  }

  method freopen (Str() $filename, Str() $mode, FILE $stream) {
    # cw: String version of MODE
    g_freopen($filename, $mode, $stream);
  }

  method fsync (Int() $fd) {
    my gint $f = $fd;

    g_fsync($f);
  }

  method lstat (Str() $filename, GStatBuf $buf) {
    g_lstat($filename, $buf);
  }

  method mkdir (Str() $filename, Int() $mode) {
    my gint $m = $mode;
    
    g_mkdir($filename, $m);
  }

  method open (Str() $filename, Int() $flags, Int() $mode) {
    my gint ($f, $m) = ($flags, $mode);

    g_open($filename, $f, $m);
  }

  method remove (Str() $filename) {
    g_remove($filename);
  }

  method rename (Str() $oldfilename, Str() $newfilename) {
    g_rename($oldfilename, $newfilename);
  }

  method rmdir (Str() $filename) {
    g_rmdir($filename);
  }

  method stat (Str() $filename, GStatBuf $buf) {
    g_stat($filename, $buf);
  }

  method unlink (Str() $filename) {
    g_unlink($filename);
  }

}
