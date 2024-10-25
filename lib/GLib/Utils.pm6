use v6.c;

use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Utils;

use GLib::Roles::StaticClass;

class GLib::Utils {
  also does GLib::Roles::StaticClass;

  method abort {
    g_abort();
  }

  method error_name (Int() $errno) is also<error-name> {
    g_strerror($errno);
  }

  method find_program_in_path (Str() $program) is also<find-program-in-path> {
    g_find_program_in_path($program);
  }

  method format_size (Int() $size) is also<format-size> {
    my guint64 $s = $size;

    g_format_size($);
  }

  method format_size_full (Int() $size, Int() $flags)
  	is also<format-size-full>
  {
    my guint64 $s = $size;
    my GFormatSizeFlags $f = $flags;

    g_format_size_full($size, $f);
  }

  method get_application_name
    is also<
      get-application-name
      application_name
      application-name
      app_name
      app-name
      appname
    >
  {
    g_get_application_name();
  }

  method get_home_dir
    is also<
      get-home-dir
      home_dir
      home-dir
      homedir
    >
  {
    g_get_home_dir();
  }

  method get_host_name
    is also<
      get-host-name
      host_name
      host-name
      hostname
    >
  {
    g_get_host_name();
  }

  method get_prgname
    is also<
      get-prgname
      program
      prg-name
      prg_name
      prog_name
      prog-name
    >
  {
    g_get_prgname();
  }

  method get_real_name
    is also<
      get-real-name
      real_name`
      real-name
    >
  {
    g_get_real_name();
  }

  method get_tmp_dir
    is also<
      get-tmp-dir
      temp_dir
      temp-dir
      tmp_dir
      tmp-dir
    >
  {
    g_get_tmp_dir();
  }

  method get_user_cache_dir
    is also<
      get-user-cache-dir
      user_cache_dir
      user-cache-dir
    >
  {
    g_get_user_cache_dir();
  }

  method get_user_config_dir
    is also<
      get-user-config-dir
      user_config_dir
      user-config-dir
    >
  {
    g_get_user_config_dir();
  }

  method get_user_data_dir
    is also<
      get-user-data-dir
      user_data_dir
      user-data-dir
    >
  {
    g_get_user_data_dir();
  }

  method get_user_name is also<
    get-user-name
    user_name
    user-name
  > {
    g_get_user_name();
  }

  method get_user_runtime_dir
    is also<
      get-user-runtime-dir
      user_runtime_dir
      user-runtime-dir
      runtime_dir
      runtime-dir
    >
  {
    g_get_user_runtime_dir();
  }

  method get_user_special_dir (Int() $directory) is also<get-user-special-dir> {
    my GUserDirectory $d = $directory;

    g_get_user_special_dir($d);
  }

  method nullify_pointer (gpointer $nullify_location) is also<nullify-pointer> {
    g_nullify_pointer($nullify_location);
  }

  proto method parse_debug_string (|)
    is also<parse-debug-string>
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

  method reload_user_special_dirs_cache is also<reload-user-special-dirs-cache> {
    g_reload_user_special_dirs_cache();
  }

  method set_application_name (Str $application_name) is also<set-application-name> {
    g_set_application_name($application_name);
  }

  method set_prgname (Str() $prgname) is also<set-prgname> {
    g_set_prgname($prgname);
  }

}
