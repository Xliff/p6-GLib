gcc glib-support.c `pkg-config --cflags gobject-2.0` -shared -fPIC -o glib-support.so `pkg-config --libs gobject-2.0`
gcc tree-helper.c -shared -fPIC -o tree-helper.so
