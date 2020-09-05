use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Env;

use GLib::Roles::StaticClass;

class GLib::Env {
  also does GLib::Roles::StaticClass;

  method environ_getenv (CArray[Str] $envp, Str $variable, :$raw = True)
    is also<
      get_environment
      get-environment
    >
  {
    my $e = g_environ_getenv($envp, $variable);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  method environ_setenv (
    CArray[Str] $envp,
    Str() $variable,
    Str() $value,
    Int() $overwrite,
    :$raw = True
  )
    is also<
      set-environment
      set_environment
    >
  {
    my gboolean $o = $overwrite.so.Int;
    my $e = g_environ_setenv($envp, $variable, $value, $o);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  method environ_unsetenv (CArray[Str] $envp, Str $variable, :$raw = True)
    is also<
      unset_environ
      unset-environ
    >
  {
    my $e = g_environ_unsetenv($envp, $variable);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  method get_environ (:$raw = True) is also<get-environ> {
    my $envp = g_get_environ();

    $raw ?? $envp !! CStringArrayToArray($envp);
  }

  method getenv (Str() $variable) is also<get> {
    g_getenv($variable);
  }

  method listenv (:$raw = True) is also<list> {
    my $envp = g_listenv();

    $raw ?? $envp !! CStringArrayToArray($envp);
  }

  proto method setenv (|)
    is also<set>
  { * }

  multi method setenv ($overwrite = False, *%env) {
    self.setenv(.key, .value, $overwrite) for %env.pairs;
  }
  multi method setenv (Str() $variable, Str() $value, Int() $overwrite) {
    my gboolean $o = $overwrite.so.Int;

    g_setenv($variable, $value, $o);
  }

  method unsetenv (Str() $variable) is also<unset> {
    g_unsetenv($variable);
  }

}
