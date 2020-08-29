use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use GLib::Raw::Enums;

unit package GLib::Raw::Test;

### /usr/include/glib-2.0/glib/gtestutils.h

sub g_test_add_data_func (
  Str $testpath,
  gconstpointer $test_data,
  &test_func (gpointer)
)
  is native(glib)
  is export
{ * }

sub g_test_add_data_func_full (
  Str $testpath,
  gpointer $test_data,
  &test_func (gpointer),
  GDestroyNotify $data_free_func
)
  is native(glib)
  is export
{ * }

sub g_test_add_func (Str $testpath, &test_func ())
  is native(glib)
  is export
{ * }

sub g_test_add_vtable (
  Str $testpath,
  gsize $data_size,
  gconstpointer $test_data,
  &data_setup (Pointer, Pointer),
  &data_test (Pointer, Pointer),
  &data_teardown (Pointer, Pointer)
)
  is native(glib)
  is export
{ * }

sub g_test_assert_expected_messages_internal (
  Str $domain,
  Str $file,
  gint $line,
  Str $func
)
  is native(glib)
  is export
{ * }

sub g_test_bug (Str $bug_uri_snippet)
  is native(glib)
  is export
{ * }

sub g_test_bug_base (Str $uri_pattern)
  is native(glib)
  is export
{ * }

# sub g_test_build_filename (GTestFileType $file_type, Str $first_path, ...)
#   returns Str
#   is native(glib)
#   is export
# { * }

sub g_test_create_case (
  Str $test_name,
  gsize $data_size,
  gconstpointer $test_data,
  &data_setup (Pointer, Pointer),
  &data_test (Pointer, Pointer),
  &data_teardown (Pointer, Pointer)
)
  returns GTestCase
  is native(glib)
  is export
{ * }

sub g_test_create_suite (Str $suite_name)
  returns GTestSuite
  is native(glib)
  is export
{ * }

sub g_test_expect_message (
  Str $log_domain,
  GLogLevelFlags $log_level,
  Str $pattern
)
  is native(glib)
  is export
{ * }

sub g_test_fail ()
  is native(glib)
  is export
{ * }

sub g_test_failed ()
  returns uint32
  is native(glib)
  is export
{ * }

sub g_assertion_message (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  Str $message
)
  is native(glib)
  is export
{ * }

sub g_assertion_message_cmpnum (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  Str $expr,
  gdouble $arg1,
  Str $cmp,
  gdouble $arg2,
  Str $numtype
)
  is native(glib)
  is export
{ * }

sub g_assertion_message_cmpstr (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  Str $expr,
  Str $arg1,
  Str $cmp,
  Str $arg2
)
  is native(glib)
  is export
{ * }

sub g_assertion_message_error (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  Str $expr,
  CArray[Pointer[GError]] $error,
  GQuark $error_domain,
  gint $error_code
)
  is native(glib)
  is export
{ * }

sub g_assertion_message_expr (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  Str $expr
)
  is native(glib)
  is export
{ * }

sub g_test_get_dir (GTestFileType $file_type)
  returns Str
  is native(glib)
  is export
{ * }

# sub g_test_get_filename (GTestFileType $file_type, Str $first_path, ...)
#   returns Str
#   is native(glib)
#   is export
# { * }

sub g_test_get_root ()
  returns GTestSuite
  is native(glib)
  is export
{ * }

sub g_test_incomplete (Str $msg)
  is native(glib)
  is export
{ * }

sub g_test_log_buffer_free (GTestLogBuffer $tbuffer)
  is native(glib)
  is export
{ * }

sub g_test_log_buffer_new ()
  returns GTestLogBuffer
  is native(glib)
  is export
{ * }

sub g_test_log_buffer_pop (GTestLogBuffer $tbuffer)
  returns GTestLogMsg
  is native(glib)
  is export
{ * }

sub g_test_log_buffer_push (
  GTestLogBuffer $tbuffer,
  guint $n_bytes,
  guint8 $bytes is rw
)
  is native(glib)
  is export
{ * }

sub g_test_log_msg_free (GTestLogMsg $tmsg)
  is native(glib)
  is export
{ * }

sub g_test_log_set_fatal_handler (
  &log_func (Str, GLogLevelFlags, Str, gpointer --> gboolean),
  gpointer $user_data
)
  is native(glib)
  is export
{ * }

sub g_test_log_type_name (GTestLogType $log_type)
  returns Str
  is native(glib)
  is export
{ * }

sub g_test_message (Str $format, Str)
  is native(glib)
  is export
{ * }

sub g_test_queue_destroy (GDestroyNotify $destroy_func, gpointer $destroy_data)
  is native(glib)
  is export
{ * }

sub g_test_rand_double ()
  returns gdouble
  is native(glib)
  is export
{ * }

sub g_test_rand_double_range (gdouble $range_start, gdouble $range_end)
  returns gdouble
  is native(glib)
  is export
{ * }

sub g_test_rand_int ()
  returns gint32
  is native(glib)
  is export
{ * }

sub g_test_rand_int_range (gint32 $begin, gint32 $end)
  returns gint32
  is native(glib)
  is export
{ * }

sub g_test_run ()
  returns gint
  is native(glib)
  is export
{ * }

sub g_test_run_suite (GTestSuite $suite)
  returns gint
  is native(glib)
  is export
{ * }

sub g_test_set_nonfatal_assertions ()
  is native(glib)
  is export
{ * }

sub g_test_skip (Str $msg)
  is native(glib)
  is export
{ * }

sub g_test_subprocess ()
  returns uint32
  is native(glib)
  is export
{ * }

sub g_test_suite_add (GTestSuite $suite, GTestCase $test_case)
  is native(glib)
  is export
{ * }

sub g_test_suite_add_suite (GTestSuite $suite, GTestSuite $nestedsuite)
  is native(glib)
  is export
{ * }

sub g_test_summary (Str $summary)
  is native(glib)
  is export
{ * }

sub g_test_timer_start ()
  is native(glib)
  is export
{ * }

sub g_test_trap_assertions (
  Str $domain,
  Str $file,
  gint $line,
  Str $func,
  guint64 $assertion_flags,
  Str $pattern
)
  is native(glib)
  is export
{ * }

sub g_test_trap_fork (guint64 $usec_timeout, GTestTrapFlags $test_trap_flags)
  returns uint32
  is native(glib)
  is export
{ * }

sub g_test_trap_has_passed ()
  returns uint32
  is native(glib)
  is export
{ * }

sub g_test_trap_reached_timeout ()
  returns uint32
  is native(glib)
  is export
{ * }

sub g_test_trap_subprocess (
  Str $test_path,
  guint64 $usec_timeout,
  GTestSubprocessFlags $test_flags
)
  is native(glib)
  is export
{ * }
