use v6.c;

use NativeCall;
use Method::Also;

use GLib::Raw::Types;
use GLib::Raw::Env;

use GLib::Roles::StaticClass;

class GLib::Env {
  also does GLib::Roles::StaticClass;

  proto method environ_getenv (|)
    is also<
      get_environment
      get-environment
    >
  { * }

  multi method environ_getenv (
    CArray[Str] $envp,
    *@vars where *.elems > 1,
    :$raw = True
  ) {
    @vars.map({ samewith($envp, $_, :$raw) });
  }
  multi method environ_getenv (
    CArray[Str] $envp,
    Str() $variable,
    :$raw = True
  ) {
    my $e = g_environ_getenv($envp, $variable);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  proto method environ_setenv (|)
    is also<
      set-environment
      set_environment
    >
  { * }

  # cw: Note that $raw CANNOT be named due to *%env!
  multi method eviron_setenv (
    CArray[Str] $envp,
    $overwrite = False,
    $raw = True,
    *%env
  ) {
    # Will leak until GC.
    my $e = $envp;
    for %env.pairs {
      $envp = self.environ_setenv($e, .key, .value, $overwrite);
    }
    $e;
  }
  multi method environ_setenv (
    CArray[Str] $envp,
    Str() $variable,
    Str() $value,
    Int() $overwrite,
    :$raw = True
  ) {
    my gboolean $o = $overwrite.so.Int;
    my $e = g_environ_setenv($envp, $variable, $value, $o);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  proto method environ_unsetenv (|)
    is also<
      unset_environ
      unset-environ
    >
  { * }

  multi method environ_unsetenv(
    CArray[Str] $envp,
    *@vars where *.elems > 1,
    :$raw = True
  ) {
    samewith($envp, $_, :$raw) for @vars;
  }
  multi method environ_unsetenv (
    CArray[Str] $envp,
    Str() $variable,
    :$raw = True
  ) {
    my $e = g_environ_unsetenv($envp, $variable);

    $raw ?? $e !! CStringArrayToArray($e);
  }

  method get_environ (:$raw = True) is also<get-environ> {
    my $envp = g_get_environ();

    $raw ?? $envp !! CStringArrayToArray($envp);
  }

  proto method getenv (|)
    is also<get>
  { * }

  multi method getenv (*@vars where *.elems > 1) {
    @vars.map({ samewith($_) });
  }
  multi method getenv (Str() $variable) {
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
  multi method setenv (
    Str() $variable,
    Str() $value,
    Int() $overwrite = False
  ) {
    my gboolean $o = $overwrite.so.Int;

    g_setenv($variable, $value, $o);
  }

  method unsetenv (Str() $variable) is also<unset> {
    g_unsetenv($variable);
  }

}
