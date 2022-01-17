use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Object;
use GLib::Raw::Structs;


unit package GLib::Raw::Env;

### /usr/include/glib-2.0/glib/genviron.h

sub g_environ_getenv (CArray[Str] $envp, Str $variable)
  returns Str
  is native(glib)
  is export
{ * }

sub g_environ_setenv (
  CArray[Str] $envp,
  Str $variable,
  Str $value,
  gboolean $overwrite
)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_environ_unsetenv (CArray[Str] $envp, Str $variable)
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_get_environ ()
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_getenv (Str $variable)
  returns Str
  is native(glib)
  is export
{ * }

sub g_listenv ()
  returns CArray[Str]
  is native(glib)
  is export
{ * }

sub g_setenv (Str $variable, Str $value, gboolean $overwrite)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_unsetenv (Str $variable)
  is native(glib)
  is export
{ * }
