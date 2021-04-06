use v6.c;

use NativeCall;

use GLib::Raw::Types;

use GLib::Class::Object;

use GLib::Roles::Pointers;

class GTypeModuleClass is repr<CStruct> does GLib::Roles::Pointers is export {
  HAS GObjectClass $.parent_class;

  # < public >
  has Pointer $!load;     # gboolean (* load)   (GTypeModule *module);
  has Pointer $!unload;   # void     (* unload) (GTypeModule *module);

  # < private >
  # Padding for future expansion
  has Pointer $!reserved1; # void (*reserved1) (void);
  has Pointer $!reserved2; # void (*reserved2) (void);
  has Pointer $!reserved3; # void (*reserved3) (void);
  has Pointer $!reserved4; # void (*reserved4) (void);
}
