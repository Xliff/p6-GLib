use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Spawn;

use GLib::Roles::StaticClass;

class GLib::Spawn {
  also does GLib::Roles::StaticClass;

  method !resolve-args($argv is raw, $envp is raw) {
    $argv = resolve-gstrv($argv) if $argv ~~ Array;
    $envp = resolve-gstrv($envp) if $envp ~~ Array;
    die '$argv must be an @array or a CArray[Str]!' unless $argv ~~ CArray[Str];
    die '$envp must be an @array or a CArray[Str]!' unless $envp ~~ CArray[Str];
  }

  multi method async (
    Str()                   $working_directory,
                            $argv, #= CArray[Str]
                            $envp, #= CArray[Str]
    Int()                   $flags,
                            &child_setup          = Callable, #= GSpawnChildSetupFunc
    gpointer                $user_data            = gpointer,
    CArray[Pointer[GError]] $error                = gerror,
  ) {
    my $rv = samewith(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      $user_data,
      $,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method async (
    Str()                   $working_directory,
                            $argv is copy, #= CArray[Str]
                            $envp is copy, #= CArray[Str]
    Int()                   $flags,
                            &child_setup,  #= GSpawnChildSetupFunc
    gpointer                $user_data,
                            $child_pid     is rw,
    CArray[Pointer[GError]] $error                = gerror,
    :$all = False
  ) {
    my GSpawnFlags $f = $flags;
    my GPid        $c = 0;

    self!resolve-args($argv, $envp);
    clear_error;
    my $rv = so g_spawn_async(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      $user_data,
      $child_pid,
      $error
    );
    set_error($error);

    $child_pid = $c;
    $all.not ?? $rv !! ($rv, $child_pid);
  }

  proto method async_with_fds (|)
      is also<async-with-fds>
  { * }

  multi method async_with_fds (
    Str()                   $working_directory,
                            $argv               is copy,
                            $envp               is copy,
    Int()                   $flags,
                            &child_setup,
    Int()                   $stdin_fd,
    Int()                   $stdout_fd,
    Int()                   $stderr_fd,
    CArray[Pointer[GError]] $error                       = gerror
  ) {
    samewith(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      gpointer,
      $stdin_fd,
      $stdout_fd,
      $stderr_fd,
      $error
    );
  }
  multi method async_with_fds (
    Str()                   $working_directory,
                            $argv               is copy,
                            $envp               is copy,
    Int()                   $flags,
                            &child_setup,
    gpointer                $user_data,
    Int()                   $stdin_fd,
    Int()                   $stdout_fd,
    Int()                   $stderr_fd,
    CArray[Pointer[GError]] $error                      = gerror
  ) {
    my $rv = samewith(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      gpointer,
      $,
      $stdin_fd,
      $stdout_fd,
      $stderr_fd,
      $error,
      :all
    );

    $rv[0] ?? $rv[1] !! Nil;
  }
  multi method async_with_fds (
    Str()                    $working_directory,
                             $argv               is copy,
                             $envp               is copy,
    Int()                    $flags,
                             &child_setup,
    gpointer                 $user_data,
                             $child_pid          is rw,
    Int()                    $stdin_fd,
    Int()                    $stdout_fd,
    Int()                    $stderr_fd,
    CArray[Pointer[GError]]  $error                       = gerror,
                            :$all                         = False
  ) {
    my gint ($si, $so, $se) = ($stdin_fd, $stdout_fd, $stderr_fd);
    my GPid            $c   =  0;
    my GSpawnFlags     $f   =  $flags;

    self!resolve-args($argv, $envp);
    clear_error;
    my $rv = g_spawn_async_with_fds(
      $working_directory,
      $argv,
      $envp,
      $f,
      &child_setup,
      $user_data,
      $c,
      $si,
      $so,
      $se,
      $error
    );
    set_error($error);
    $child_pid = $c;
    $all.not ?? $rv !! ($rv, $child_pid);
  }

  proto method async_with_pipes (|)
      is also<async-with-pipes>
  { * }

  multi method async_with_pipes (
    Str()    $working_directory,
             $argv,
             $envp,
    Int()    $flags,
             &child_setup          = Callable,
    gpointer $user_data            = gpointer,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $rv = samewith(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      $user_data,
      $,
      $,
      $,
      $,
      $error,
      :all
    );

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method async_with_pipes (
    Str()                    $working_directory,
                             $argv,
                             $envp,
    Int()                    $flags,
                             &child_setup,
    gpointer                 $user_data,
                             $child_pid          is rw, #= GPid
                             $standard_input     is rw, #= gint
                             $standard_output    is rw, #= gint
                             $standard_error     is rw, #= gint
    CArray[Pointer[GError]]  $error                              = gerror,
                            :$all                                = False
  ) {
    my GPid         $c             = 0;
    my GSpawnFlags  $f             = $flags;
    my gint        ($si, $so, $se) = 0 xx 3;

    self!resolve-args($argv, $envp);
    clear_error;
    my $rv = so g_spawn_async_with_pipes(
      $working_directory,
      $argv,
      $envp,
      $f,
      &child_setup,
      $user_data,
      $c,
      $si,
      $so,
      $se,
      $error
    );
    set_error($error);
    ($child_pid, $standard_input, $standard_output, $standard_error) =
      ($c, $si, $so, $se);
    $all.not ?? $rv !! ($rv, $c, $si, $so, $se);
  }

  method check_exit_status (
    Int()                   $exit_status,
    CArray[Pointer[GError]] $error        = gerror
  )
    is also<check-exit-status>
  {
    my gint $e = $exit_status;

    clear_error;
    my $rv = so g_spawn_check_exit_status($e, $error);
    set_error($error);
    $rv;
  }

  method close_pid (Int() $pid) is also<close-pid> {
    my GPid $p = $pid;

    so g_spawn_close_pid($p);
  }

  method command_line_async (
    Str()                   $command_line,
    CArray[Pointer[GError]] $error         = gerror
  )
    is also<command-line-async>
  {
    clear_error;
    my $rv = g_spawn_command_line_async($command_line, $error);
    set_error($error);
    $rv;
  }

  proto method command_line_sync (|)
      is also<command-line-sync>
  { * }

  multi method command_line_sync (
    Str()                   $command_line,
    CArray[Pointer[GError]] $error         = gerror,
  ) {
    samewith($command_line, $, $, $, $error, :all);
  }
  multi method command_line_sync (
    Str()                    $command_line,
                             $standard_output is rw,
                             $standard_error  is rw,
                             $exit_status     is rw,
    CArray[Pointer[GError]]  $error                  = gerror,
                            :$all                    = False
  ) {
    my gint $e        = 0;
    my     ($so, $se) = newCArray(Str) xx 2;

    clear_error;
    my $rv = g_spawn_command_line_sync(
      $command_line,
      $so,
      $se,
      $e,
      $error
    );
    set_error($error);
    ($standard_output, $standard_error, $exit_status) = ppr($so, $se, $e);
    $all.not ?? $rv !! ($rv, $standard_output, $standard_error, $exit_status);
  }

  method error_quark (GLib::Spawn:U: ) is also<error-quark> {
    g_spawn_error_quark();
  }

  method exit_error_quark (GLib::Spawn:U: ) is also<exit-error-quark> {
    g_spawn_exit_error_quark();
  }

  multi method sync (
    Str()                   $working_directory,
                            $argv,
                            $envp,
    Int()                   $flags,
                            &child_setup         = Callable,
    gpointer                $user_data           = gpointer,
    CArray[Pointer[GError]] $error               = gerror
  ) {
    my $rv = samewith(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      $user_data,
      $,
      $,
      $,
      $error,
      :all
    );

    $rv[0] ?? $rv.skip(1) !! Nil;
  }
  multi method sync (
    Str()                    $working_directory,
                             $argv,
                             $envp,
    Int()                    $flags,
                             &child_setup,
    gpointer                 $user_data,
                             $standard_output     is rw,
                             $standard_error      is rw,
                             $exit_status         is rw,
    CArray[Pointer[GError]]  $error                      = gerror,
                            :$all                        = False
  ) {
    my GSpawnFlags $f = $flags;
    my gint $e = 0;
    my ($so, $se) = newCArray(Str) xx 2;

    self!resolve-args($argv, $envp);
    clear_error;
    my $rv = so g_spawn_sync(
      $working_directory,
      $argv,
      $envp,
      $flags,
      &child_setup,
      $user_data,
      $so,
      $se,
      $e,
      $error
    );
    set_error($error);
    ($standard_output, $standard_error, $exit_status) = ppr($so, $se, $e);
    $all.not ?? $rv !! ($rv, $standard_output, $standard_error, $exit_status);
  }

}
