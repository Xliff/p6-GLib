use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GLib::Raw::Enums;

unit package GLib::Raw::Spawn;

### /usr/include/glib-2.0/glib/gspawn.h

sub g_spawn_async (
  Str $working_directory,
  CArray[Str] $argv,
  CArray[Str] $envp,
  GSpawnFlags $flags,
  &child_setup (gpointer), #= GSpawnChildSetupFunc
  gpointer $user_data,
  GPid $child_pid is rw,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_async_with_fds (
  Str $working_directory,
  CArray[Str] $argv,
  CArray[Str] $envp,
  GSpawnFlags $flags,
  &child_setup (gpointer), #= GSpawnChildSetupFunc
  gpointer $user_data,
  GPid $child_pid is rw,
  gint $stdin_fd  is rw,
  gint $stdout_fd is rw,
  gint $stderr_fd is rw,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_async_with_pipes (
  Str $working_directory,
  CArray[Str] $argv,
  CArray[Str] $envp,
  GSpawnFlags $flags,
  &child_setup (gpointer), #= GSpawnChildSetupFunc
  gpointer $user_data,
  GPid $child_pid       is rw,
  gint $standard_input  is rw,
  gint $standard_output is rw,
  gint $standard_error  is rw,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_check_exit_status (
  gint $exit_status,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_close_pid (GPid $pid)
  is native(glib)
  is export
{ * }

sub g_spawn_command_line_async (
  Str $command_line,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_command_line_sync (
  Str $command_line,
  CArray[Str] $standard_output,
  CArray[Str] $standard_error,
  gint $exit_status is rw,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_spawn_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_spawn_exit_error_quark ()
  returns GQuark
  is native(glib)
  is export
{ * }

sub g_spawn_sync (
  Str $working_directory,
  Str $argv,
  Str $envp,
  GSpawnFlags $flags,
  &child_setup (gpointer), #= GSpawnChildSetupFunc
  gpointer $user_data,
  CArray[Str] $standard_output,
  CArray[Str] $standard_error,
  gint $exit_status,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(glib)
  is export
{ * }
