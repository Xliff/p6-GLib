use v6.c;

use NativeCall;

use GLib::Raw::Types;
use GLib::Raw::Log;

use GLib::Roles::StaticClass;
use GLib::Roles::TypedBuffer;

my (
  &writer-func,
  &default-handler,
  &print-handler,
  &printerr-handler,
  %handlers
);

class GLib::Log {
  also does GLib::Roles::StaticClass;

  method log (Str() $log_domain, Int() $log_level, Str() $format) {
    my guint $ll = $log_level;

    g_log($log_domain, $ll, $format);
  }

  method message (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_MESSAGE,  $format);
  }

  method critical (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_CRITICAL, $format);
  }

  method error (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_ERROR,    $format);
  }

  method warn (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_WARNING,  $format);
  }

  method info (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_INFO,     $format);
  }

  method debug (Str() $format) {
    GLib::Log.log('GLib', G_LOG_LEVEL_DEBUG,    $format);
  }

  method default_handler (
    Str() $log_domain,
    Int() $log_level,
    Str() $message,
    gpointer $unused_data = gpointer
  ) {
    g_log_default_handler($log_domain, $log_level, $message, $unused_data);
  }

  # method logv (Str() $log_domain, Int() $log_level, Str() $format, va_list $args) {
  #   g_logv($log_domain, $log_level, $format, $args);
  # }
  #
  # method printf_string_upper_bound (Str() $format, va_list $args) {
  #   g_printf_string_upper_bound($format, $args);
  # }

  method return_if_fail_warning (
    Str() $log_domain,
    Str() $pretty_function,
    Str() $expression
  ) {
    g_return_if_fail_warning($log_domain, $pretty_function, $expression);
  }

  proto method is-handler-set (|)
  { * }

  multi method is-handler-set ('default') {
    &default-handler.defined;
  }
  multi method is-handler-set ('print') {
    &print-handler.defined;
  }
  multi method is-handler-set ('print-err') {
    &printerr-handler.defined;
  }
  multi method is-handler-set ('writer') {
    &writer-func.defined;
  }
  multi method is-handler-set ($hid) {
    %handlers{$hid}.defined;
  }

  method set_print_handler (&func) {
    &print-handler = &func;
    g_set_print_handler(&func);
  }

  method set_printerr_handler (&func) {
    &printerr-handler = &func;
    g_set_printerr_handler(&func);
  }

  method warn_message (
    Str() $domain,
    Str() $file,
    Int() $line,
    Str() $func,
    Str() $warnexpr
  ) {
    my gint $l = $line;

    g_warn_message($domain, $file, $l, $func, $warnexpr);
  }

  method remove_handler (Str() $log_domain, Int() $handler_id) {
    my guint $hid = $handler_id;

    g_log_remove_handler($log_domain, $hid);
    %handlers{$hid}:delete;
  }

  method set_always_fatal (Int() $fatal_mask) {
    g_log_set_always_fatal($fatal_mask);
  }

  method set_default_handler (
             &log_func,
    gpointer $user_data = gpointer
  ) {
    my $oh = g_log_set_default_handler(&log_func, $user_data);
    &default-handler = &log_func;
    $oh;
  }

  method set_fatal_mask (Str() $log_domain, Int() $fatal_mask) {
    my guint $fm = $fatal_mask;

    g_log_set_fatal_mask($log_domain, $fm);
  }

  method set_handler (
    Str()    $log_domain,
    Int()    $log_levels,
             &log_func,
    gpointer $user_data   = gpointer
  ) {
    my guint $ll = $log_levels;

    my $hid = g_log_set_handler($log_domain, $ll, &log_func, $user_data);
    %handlers{$hid} = &log_func;
    $hid;
  }

  method set_handler_full (
    Str()          $log_domain,
    Int()          $log_levels,
                   &log_func,
    gpointer       $user_data   = gpointer,
    GDestroyNotify $destroy     = gpointer
  ) {
    my guint $ll = $log_levels;

    my $hid = g_log_set_handler_full(
      $log_domain,
      $ll,
      &log_func,
      $user_data,
      $destroy
    );
    %handlers{$hid} = &log_func;
  }

  method reset_writer_func {
    self.set_writer_func(&g_log_writer_default);
    &writer-func = Nil;
  }

  method set_writer_func (
             &func,
    gpointer $user_data      = gpointer,
             &user_data_free = %DEFAULT-CALLBACKS<GDestroyNotify>
  ) {
    &writer-func = &func;
    g_log_set_writer_func(&func, $user_data, &user_data_free);
  }

  proto method log_structured_array (|)
  { * }

  multi method log_structured_array (
    Int() $log_level,
          @fields
  ) {
    samewith(
      $log_level,
      GLib::Roles::TypedfBuffer[GLogField].new(@fields).p,
      @fields.elems
    )
  }
  multi method log_structured_array (
    Int()    $log_level,
    gpointer $fields,
    Int()    $n_fields
  ) {
    my guint $ll = $log_level;
    my uint64 $nf = $n_fields;

    g_log_structured_array($ll, $fields, $nf);
  }

  method variant (Str() $log_domain, Int() $log_level, GVariant() $fields) {
    my guint $ll = $log_level;

    g_log_variant($log_domain, $log_level, $fields);
  }

  proto method writer_default (|)
  { * }

  multi method writer_default (
    Int()    $log_level,
             @fields,
    gpointer $user_data   = gpointer
  ) {
    samewith(
      $log_level,
      GLib::Roles::TypedBuffer[GLogField].new(@fields).p,
      @fields.elems,
      $user_data
    );
  }
  multi method writer_default (
    Int()    $log_level,
    gpointer $fields,
    Int()    $n_fields,
    gpointer $user_data = gpointer
  ) {
    my guint  $ll = $log_level;
    my uint64 $nf = $n_fields;

    g_log_writer_default($ll, $fields, $nf, $user_data);
  }

  proto method writer_format_fields (|)
  { * }

  multi method writer_format_fields (
    Int() $log_level,
          @fields,
    Int() $use_color
  ) {
    samewith(
      $log_level,
      GLib::Roles::TypedBuffer[GLogField].new(@fields).p,
      @fields.elems,
      $use_color
    );
  }
  multi method writer_format_fields (
    Int()    $log_level,
    gpointer $fields,
    Int()    $n_fields,
    Int()    $use_color
  ) {
    my guint $ll = $log_level;
    my uint64 $nf = $n_fields;
    my gboolean $uc = so $use_color;

    g_log_writer_format_fields($ll, $fields, $nf, $uc);
  }

  # Handle IO::Handle, too?
  method writer_is_journald (Int() $output_fd) {
    my guint $of = $output_fd;

    g_log_writer_is_journald($of);
  }

  proto method writer_journald (|)
  { * }

  multi method writer_journald (
    Int() $log_level,
          @fields,
    Int() $user_data = gpointer
  ) {
    samewith(
      $log_level,
      GLib::Roles::TypedBuffer[GLogField].new(@fields).p,
      @fields.elems,
      $user_data
    );
  }
  multi method writer_journald (
    Int()    $log_level,
    gpointer $fields,
    Int()    $n_fields,
    Int()    $user_data = gpointer
  ) {
    my guint  $ll = $log_level;
    my uint64 $nf = $n_fields;

    g_log_writer_journald($ll, $fields, $nf, $user_data);
  }

  proto method writer_standard_streams (|)
  { * }

  multi method writer_standard_streams (
    Int() $log_level,
          @fields,
    Int() $user_data = gpointer
  ) {
    samewith(
      $log_level,
      GLib::Roles::TypedBuffer[GLogField].new(@fields).p,
      @fields.elems,
      $user_data
    );
  }
  multi method writer_standard_streams (
    Int()    $log_level,
    gpointer $fields,
    Int()    $n_fields,
    Int()    $user_data = gpointer
  ) {
    my guint  $ll = $log_level;
    my uint64 $nf = $n_fields;

    g_log_writer_standard_streams($ll, $fields, $nf, $user_data);
  }

  # Handle IO::Handle, too?
  method writer_supports_color (Int() $output_fd) {
    my guint $of = $output_fd;

    g_log_writer_supports_color($of);
  }

}
