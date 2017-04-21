Luis Daniel Hernández Carrera A01360411
Jesus Alejandro Torres Vázquez A01184899

This program analyzes a entry in the form of a file, using lexical, syntactic and semantic analysis tells if the entry is well written according to the grammar of the Tiny C language.

A symbol table in the form of a hash table is implemented to store the identificators found
during the analysis.

The semantic analysis for 
The program prints warnings if a semantic error is detected.

To compile and run the program, flex, bison and gcc are needed.

Steps (Linux):
1) flex tinyc.l
2) bison tinyc.y
3) gcc -o 'name' tinyc.tab.c UserDefined.c `pkg-config --cflags --libs glib-2.0` -lfl
4) ./'name' 'InputFile'

To compile the program in an easier way, run the shell file make.sh
1) sh make.sh

This will generate the executable pato. To run the program do
1) ./pato 'InputFile'