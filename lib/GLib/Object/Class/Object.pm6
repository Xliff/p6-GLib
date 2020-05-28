use v6.c;

use NativeCall;

use GLib::Raw::Types;

use GLib::Roles::Pointers;

class GObjectClass          is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GTypeClass      $.g_type_class;
  # Private
  has GSList          $!construct_properties;
  # Public
  has Pointer         $.constructor;                 #= GObject*   (*constructor)     (GType                  type,
                                                     #=                                guint                  n_construct_properties,
                                                     #=                                GObjectConstructParam *construct_properties);
  # overridable methods
  has Pointer         $.set_property;                #= void       (*set_property)            (GObject        *object,
                                                     #=                                        guint           property_id,
                                                     #=                                        const GValue   *value,
                                                     #=                                        GParamSpec     *pspec);
  has Pointer         $.get_property;                #= void       (*get_property)            (GObject        *object,
                                                     #=                                        guint           property_id,
                                                     #=                                        GValue         *value,
                                                     #=                                        GParamSpec     *pspec);
  has Pointer         $.dispose;                     #= void       (*dispose)                 (GObject        *object);
  has Pointer         $.fiinalize;                   #= void       (*finalize)                (GObject        *object);
  # seldom overriden
  has Pointer         $.dispatch_properties_changed; #= void       (*dispatch_properties_changed) (GObject      *object,
                                                     #=                                            guint         n_pspecs,
                                                     #=                                            GParamSpec  **pspecs);
  # signals
  has Pointer         $.notify;                      #= void       (*notify)                  (GObject        *object,
                                                     #=                                        GParamSpec     *pspec);

  # called when done constructing
  has Pointer         $.constructed;                 #= void       (*constructed)             (GObject        *object);

  # Private
  has gsize           $!flags;
  HAS gpointer        @!pdummy[6] is CArray;
}

constant GInitiallyUnownedClass is export := GObjectClass;
