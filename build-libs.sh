#!/bin/sh

gcc glib-support.c `pkg-config --cflags gobject-2.0` -shared -fPIC -o glib-support.so `pkg-config --libs gobject-2.0`
gcc tree-support.c `pkg-config --cflags gobject-2.0` -shared -fPIC -o tree-support.so `pkg-config --libs gobject-2.0`
