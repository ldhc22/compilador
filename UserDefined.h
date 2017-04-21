
/* Luis Daniel Hernández Carrera	A01360411
 * Jesus Torres Vazquez 			A01184899
 *
 * File with the declaration of the functions and structures
 * to be used for the implementation of the symbol table 
 * in the syntactic and lexical analyzer.
 *
 */
#include <glib.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

enum myTypes {integer, real};			/* Types to be used. Boolean = integer*/

union val {            
   int     i_value;                  	/* Interpret it as an integer */
   float   r_value;                   	/* Interpret it as a float */
};

	/* Structure that holds the information we need for the symbol table*/
typedef struct tableEntry_{
	char * 			name;
	enum myTypes	type;		
	union val 		value;		
}tableEntry;

typedef struct tableEntry_ *entry_p;

	/* Specifies how to print each of the items in the symbol table 				*/
int PrintItem(entry_p my_item);
	
	/* Helper print funtion to use in the g_hash_foreach method 					*/
int PrintSymbol(gpointer key,gpointer value, gpointer data);

	/* Uses the functions above to print every entry of the symbol table 			*/
int PrintTable(GHashTable * my_table);

	/* Insert a symbol into the table by allocating memory and using g_hash_insert 	*/
void SymInsert(GHashTable *myTable, char * name, enum myTypes type);

	/* Looks up a key in the given hash table. It duplicates the entry found and   	*/
	/* returns a pointer to the new structure, or returns NULL if nothing is found 	*/
entry_p SymLookUp(GHashTable *myTable, char *name);

	/* Specifies how to destroy the data structure used in the table 				*/
void FreeItem(gpointer my_entry);

	/* Finds the entry in the symbol table and update the values of the structure 	*/
void SymUpdate(GHashTable *myTable, char * name, enum myTypes type, union val value);

entry_p newTemp(GHashTable *myTable);