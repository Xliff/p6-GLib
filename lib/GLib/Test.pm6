use v6.c;

use Method::Also;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Test;
use GLib::Raw::Log;

use GLib::Log;

use GLib::Roles::StaticClass;

class GLib::Test::Log { ... }

class GLib::Test {
  also does GLib::Roles::StaticClass;

  method add_data_func (
    Str() $testpath,
    gconstpointer $test_data,
    &test_func
  )
    is also<add-data-func>
  {
    g_test_add_data_func($testpath, $test_data, &test_func);
  }

  proto method add_data_func_full (|)
      is also<add-data-func-full>
  { * }

  multi method add_data_func_full (
    Str() $testpath,
    &test_func,
    gpointer $test_data            = gpointer,
    GDestroyNotify $data_free_func = gpointer
  ) {
    samewith($testpath, $test_data, &test_func, $data_free_func);
  }
  multi method add_data_func_full (
    Str() $testpath,
    gpointer $test_data,
    &test_func,
    GDestroyNotify $data_free_func
  ) {
    g_test_add_data_func_full(
      $testpath,
      $test_data,
      &test_func,
      $data_free_func
    );
  }

  method add_func (Str() $testpath, &test_func) is also<add-func> {
    g_test_add_func($testpath, &test_func);
  }

  proto method add_vtable (|)
      is also<add-vtable>
  { * }

  multi method add_vtable (
    Str() $testpath,
    %funcs,
    Int() $data_size,
    gpointer $test_data = gpointer,
  ) {
    samewith($testpath, $data_size, $test_data, |%funcs);
  }
  multi method add_vtable (
    Str() $testpath,
    Int() $data_size,
    gpointer $test_data = gpointer,
    *%funcs
  ) {
    die '%funcs must have at least one of "setup", "tests" or "teardown" keys set!'
      unless %funcs<
        data_setup data_test data_teardown
             setup      test      teardown
      >.any.defined;

    samewith(
      $testpath,
      $data_size,
      $test_data,
      %funcs<data_setup>    // %funcs<setup>,
      %funcs<data_test>     // %funcs<test>,
      %funcs<data_teardown> // %funcs<teardown>
    );
  }
  multi method add_vtable (
    Str() $testpath,
    Int() $data_size,
    gconstpointer $test_data,
    &data_setup,
    &data_test,
    &data_teardown
  ) {
    my gsize $ds = $data_size;
    g_test_add_vtable(
      $testpath,
      $ds,
      $test_data,
      &data_setup,
      &data_test,
      &data_teardown
    );
  }

  method assert_expected_messages is also<assert-expected-messages> {
    self!assert_expected_messages_internal(
      G_LOG_DOMAIN,
      $*FILE,
      $*LINE,
      # This should be the function name of the caller.
      'calling routine'
    );
  }

  method !assert_expected_messages_internal (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func
  ) {
    my gint $l = $line;

    g_test_assert_expected_messages_internal($domain, $file, $l, $func);
  }

  method bug (Str() $bug_uri_snippet) {
    g_test_bug($bug_uri_snippet);
  }

  method bug_base (Str() $uri_pattern) is also<bug-base> {
    g_test_bug_base($uri_pattern);
  }

  # method build_filename (GTestFileType $file_type, Str $first_path, ...) {
  #   g_test_build_filename($file_type, $first_path);
  # }

  # method create_case (
  #   Str $test_name,
  #   gsize $data_size,
  #   gconstpointer $test_data,
  #   GTestFixtureFunc $data_setup,
  #   GTestFixtureFunc $data_test,
  #   GTestFixtureFunc $data_teardown
  # ) {
  #   g_test_create_case($test_name, $data_size, $test_data, $data_setup, $data_test, $data_teardown);
  # }

  method expect_message (Str() $log_domain, Int() $log_level, Str() $pattern)
    is also<expect-message>
  {
    my GLogLevelFlags $ll = $log_level;

    g_test_expect_message($log_domain, $ll, $pattern);
  }

  method fail {
    g_test_fail();
  }

  method failed {
    g_test_failed();
  }

  method g_assertion_message (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func,
    Str() $message
  )
    is also<g-assertion-message>
  {
    my gint $l = $line;

    g_assertion_message($domain, $file, $l, $func, $message);
  }

  method g_assertion_message_cmpnum (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func,
    Str() $expr,
    Num() $arg1,
    Str() $cmp,
    Num() $arg2,
    Str() $numtype
  )
    is also<g-assertion-message-cmpnum>
  {
    my gint $l = $line;
    my gdouble ($a1, $a2) = ($arg1, $arg2);

    g_assertion_message_cmpnum(
      $domain,
      $file,
      $l,
      $func,
      $expr,
      $a1,
      $cmp,
      $a2,
      $numtype
    );
  }

  method g_assertion_message_cmpstr (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func,
    Str() $expr,
    Str() $arg1,
    Str() $cmp,
    Str() $arg2
  )
    is also<g-assertion-message-cmpstr>
  {
    my gint $l = $line;

    g_assertion_message_cmpstr(
      $domain,
      $file,
      $l,
      $func,
      $expr,
      $arg1,
      $cmp,
      $arg2
    );
  }

  # method g_assertion_message_error (
  #   Str() $domain,
  #   Str() $file,
  #   Int() $line,
  #   Str() $func,
  #   Str() $expr,
  #   CArray[Pointer[GError]] $error,
  #   GQuark $error_domain,
  #   gint $error_code
  # ) {
  #   my gint $l = $line;
  #   my gint $e = $error_code;
  #
  #   g_assertion_message_error($domain, $file, $l, $func, $expr, $error, $error_domain, $e);
  # }
  #
  # method g_assertion_message_expr (
  #   Str() $domain,
  #   Str() $file,
  #   Int() $line,
  #   Str() $func,
  #   Str() $expr
  # ) {
  #   my gint $l = $line;
  #
  #   g_assertion_message_expr($domain, $file, $line, $func, $expr);
  # }

  method get_dir (Int() $file_type) is also<get-dir> {
    my GTestFileType $f = $file_type;

    g_test_get_dir($f);
  }

  # method get_filename (GTestFileType $file_type, Str $first_path, ...) {
  #   g_test_get_filename($file_type, $first_path);
  # }

  method get_root is also<get-root> {
    g_test_get_root();
  }

  method incomplete (Str() $msg) {
    g_test_incomplete($msg);
  }

  # method log_buffer_free (GTestLogBuffer $tbuffer) {
  #   g_test_log_buffer_free($tbuffer);
  # }
  #
  # method log_buffer_new {
  #   g_test_log_buffer_new();
  # }
  #
  # method log_buffer_pop (GTestLogBuffer $tbuffer) {
  #   g_test_log_buffer_pop($tbuffer);
  # }
  #
  # method log_buffer_push (GTestLogBuffer $tbuffer, guint $n_bytes, guint8 $bytes is rw) {
  #   g_test_log_buffer_push($tbuffer, $n_bytes, $bytes is rw);
  # }
  #
  # method log_msg_free (GTestLogMsg $tmsg) {
  #   g_test_log_msg_free($tmsg);
  # }
  #
  # method log_set_fatal_handler (&log_func, gpointer $user_data = gpointer) {
  #   g_test_log_set_fatal_handler(&log_func, $user_data);
  # }
  #
  # method log_type_name (Int() $log_type) {
  #   my GTestLogType $l = $log_type;
  #
  #   g_test_log_type_name($l);
  # }

  method message (Str() $message,) {
    g_test_message($message, Str);
  }

  method queue_destroy (
    GDestroyNotify $destroy_func = gpointer,
    gpointer $destroy_data       = gpointer
  )
    is also<queue-destroy>
  {
    g_test_queue_destroy($destroy_func, $destroy_data);
  }

  method rand_double is also<rand-double> {
    g_test_rand_double();
  }

  method rand_double_range (Num() $range_start, Num() $range_end)
    is also<rand-double-range>
  {
    my gdouble ($s, $e) = ($range_start, $range_end);

    g_test_rand_double_range($s, $e);
  }

  method rand_int is also<rand-int> {
    g_test_rand_int();
  }

  method rand_int_range (Int() $begin, Int() $end) is also<rand-int-range> {
    my gint32 ($b, $e) = ($begin, $end);

    g_test_rand_int_range($b, $e);
  }

  method run {
    g_test_run();
  }

  method set_nonfatal_assertions is also<set-nonfatal-assertions> {
    g_test_set_nonfatal_assertions();
  }

  method skip (Str $msg) {
    g_test_skip($msg);
  }

  method subprocess {
    g_test_subprocess();
  }

  method summary (Str $summary) {
    g_test_summary($summary);
  }

  method timer_start is also<timer-start> {
    g_test_timer_start();
  }

  method trap_assertions (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func,
    Int() $assertion_flags,
    Str $pattern
  )
    is also<trap-assertions>
  {
    my gint $l = $line;
    my guint64 $a = $assertion_flags;

    g_test_trap_assertions($domain, $file, $l, $func, $a, $pattern);
  }

  method trap_fork (Int() $usec_timeout, Int() $test_trap_flags)
    is also<trap-fork>
  {
    my guint64 $u = $usec_timeout;
    my GTestTrapFlags $t = $test_trap_flags;

    g_test_trap_fork($u, $t);
  }

  method trap_has_passed is also<trap-has-passed> {
    g_test_trap_has_passed();
  }

  method trap_reached_timeout is also<trap-reached-timeout> {
    g_test_trap_reached_timeout();
  }

  method trap_subprocess (
    Str() $test_path,
    Int() $usec_timeout,
    Int() $test_flags
  )
    is also<trap-subprocess>
  {
    my guint64 $u = $usec_timeout;
    my GTestSubprocessFlags $t = $test_flags;

    g_test_trap_subprocess($test_path, $u, $t);
  }

}

class GLib::Test::Suite {
  has GTestSuite $!ts;

  submethod BUILD (:$tests) {
    $!ts = $tests;
  }

  method GLib::Raw::Definitions::GTestSuite
  { $!ts }

  multi method new (GTestSuite $tests) {
    $tests ?? self.bless( :$tests ) !! Nil;
  }
  multi method new (Str() $suite_name) {
    GLib::Test::Suite.create($suite_name);
  }

  method create (GLib::Test::Suite:U: Str() $suite_name) {
    my $tests = g_test_create_suite($suite_name);

    $tests ?? self.bless( :$tests ) !! Nil;
  }

  method add (GTestCase() $test_case) {
    g_test_suite_add($!ts, $test_case);
  }

  method add_suite (GTestSuite() $nestedsuite) is also<add-suite> {
    g_test_suite_add_suite($!ts, $nestedsuite);
  }

  method run {
    g_test_run_suite($!ts);
  }

}

class GLib::Test::Log {
  has %!expected-messages;
  has $!using-handler;

  submethod BUILD (:$log-levels) {
    $!using-handler = False;
    unless GLib::Log.is-handler-set('writer') {
      GLib::Log.set_writer_func( sub ($ll, $f, $n, $ud --> GLogWriterOutput) {
        CATCH { default { .message.say; } }

        my $fields = GLib::Roles::TypedBuffer[GLogField].new-typedbuffer-obj(
          $f,
          :!autosize
        );
        $fields.setSize($n, :forced);

        for $fields.Array -> \𝑓 {
          next unless 𝑓.length; # Pointer
          # copy string data if $f.length > 0
          # NUL-terminated if $f.length = -1 (default)
          for %!expected-messages.kv -> $k, $v {
            next if %!expected-messages{$k};
            next unless 𝑓.key eq 'MESSAGE';
            self.encountered($k) if 𝑓.getValueStr.contains($k);
          }
        }

        # For the purposes of GLib::Test::Log, we don't handle ANYTHING!
        return G_LOG_WRITER_UNHANDLED
      });
      $!using-handler = True;
    }
  }

  submethod DESTROY {
    self.done;
  }

  method new ($log-levels) {
    self.bless( :$log-levels );
  }

  method done {
    GLib::Log.set_writer_func(&g_log_writer_default) if $!using-handler;
  }

  method expect ($message) {
    %!expected-messages{$message} = False;
  }

  method encountered ($message) {
    %!expected-messages{$message} = True;
  }

  method got-expected {
    [&&]( |%!expected-messages.values )
  }
}
