use v6.c;

use GLib::Raw::Types;
use GLib::Raw::Utils;

use GLib::Roles::StaticClass;

class GLib::Utils {
  also does GLib::Roles::StaticClass;

  method abort {
    g_abort();
  }

  method find_program_in_path (Str $program) {
    g_find_program_in_path($program);
  }

  method format_size (Int() $size) {
    my guint64 $s = $size;

    g_format_size($);
  }

  method format_size_full (Int() $size, Int() $flags) {
    my guint64 $s = $size;
    my GFormatSizeFlags $f = $flags;

    g_format_size_full($size, $f);
  }

  method get_application_name {
    g_get_application_name();
  }

  method get_home_dir {
    g_get_home_dir();
  }

  method get_host_name {
    g_get_host_name();
  }

  method get_prgname {
    g_get_prgname();
  }

  method get_real_name {
    g_get_real_name();
  }

  method get_tmp_dir {
    g_get_tmp_dir();
  }

  method get_user_cache_dir {
    g_get_user_cache_dir();
  }

  method get_user_config_dir {
    g_get_user_config_dir();
  }

  method get_user_data_dir {
    g_get_user_data_dir();
  }

  method get_user_name {
    g_get_user_name();
  }

  method get_user_runtime_dir {
    g_get_user_runtime_dir();
  }

  method get_user_special_dir (Int() $directory) {
    my GUserDirectory $d = $directory;

    g_get_user_special_dir($d);
  }

  method nullify_pointer (gpointer $nullify_location) {
    g_nullify_pointer($nullify_location);
  }

  proto method parse_debug_string (|)
  { * }

  multi method parse_debug_string (Str() $string, @keys) {
    die '@keys must only contain GDebugKey entries!'
      unless @keys.all ~~ GDebugKey;
      
    samewith($string, GLib::Roles::TypedBuffer.new(@keys), @keys.elem)
  }
  multi method parse_debug_string (
    Str() $string,
    gpointer $keys,
    Int() $nkeys
  ) {
    my guint $n = $nkeys;

    g_parse_debug_string($string, $keys, $n);
  }

  method reload_user_special_dirs_cache {
    g_reload_user_special_dirs_cache();
  }

  method set_application_name (Str $application_name) {
    g_set_application_name($application_name);
  }

  method set_prgname (Str() $prgname) {
    g_set_prgname($prgname);
  }

}
