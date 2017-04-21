flex tinyc.l

bison tinyc.y

gcc -o pato tinyc.tab.c UserDefined.c FileManagement.c `pkg-config --cflags --libs glib-2.0` -lfl