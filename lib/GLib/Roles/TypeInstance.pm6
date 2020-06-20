use v6.c;

use GLib::Raw::Enums;

role GLib::Roles::TypeInstance {

  method checkType ($compare_type) {
    self.g_type_instance.checkType($compare_type)
  }

  method getType {
    self.g_type_instance.getType
  }

}
