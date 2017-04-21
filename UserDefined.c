/* Luis Daniel Hernández Carrera	A01360411
 * Jesus Torres Vazquez 			A01184899
 *
 * File with the funtions to handle the symbol table
 * using hash tables and the functions already defined
 * in glib
 *
 */

#include "UserDefined.h"

	/* Prints the information of each node in the symbol table*/
int PrintItem(entry_p my_item){
	printf("Name: %s\nType: %d\n", my_item->name,my_item->type);
	if(my_item->type == integer)
		printf("%d\n",my_item->value.i_value );
	else
		printf("%f\n",my_item->value.r_value );
	return EXIT_SUCCESS;
}


int PrintSymbol(gpointer key,gpointer value, gpointer data){
		/* Print the entry and a division */
      PrintItem(value);
      printf("----------------------------\n");
      return EXIT_SUCCESS;
}

int PrintTable(GHashTable * my_table){
		/* Print a fancy title for the table */
	printf("Symbol Table for the program:\n");
	printf("=============================\n");
		/* Print each of the entries with the function defined in glib */
	g_hash_table_foreach(my_table,(GHFunc)PrintSymbol,NULL);
	return EXIT_SUCCESS;
}

	/* Creates the entry and then inserts it in the table */
void SymInsert(GHashTable *myTable, char * name, enum myTypes type){
	entry_p node = malloc(sizeof(struct tableEntry_));
	node->name = strdup(name);
	node->type = type;

	/* Initialize every variable as 0*/
	if(type == real)
		node->value.r_value = 0.0;
	else
		node->value.i_value = 0;
	g_hash_table_insert(myTable,node->name,node);
}

	/* Looks for an entry in the symbol table using the name as a key 	*/
	/* Returns NULL if nothing is found 								*/
entry_p SymLookUp(GHashTable *myTable, char *name){
	entry_p item 		= malloc(sizeof(entry_p));
    entry_p symEntry 	= g_hash_table_lookup(myTable,name);

    /* Duplicate the node to avoid changing the information of the nodes */
    if(symEntry != NULL){
    	item->name 		= symEntry->name;	//The name is never modified, so theres no need to duplicate it
	    item->value 	= symEntry->value;
	    item->type 		= symEntry->type; 
	    return item;	
    }
    return NULL;       
}
	/* Frees the string used in each of the entries */
void FreeItem(gpointer  my_entry){
	free(((entry_p)my_entry)->name);
}
	/* Finds an entry using the name as the key */
	/* Then, it modifies the values in the structure to Update the node */
void SymUpdate(GHashTable *myTable, char * name, enum myTypes type, union val value){
	entry_p node = g_hash_table_lookup(myTable,name);
	if(node != NULL){
		node->type = type;
		node->value = value;	
	}
}

entry_p newTemp(GHashTable *myTable){
	char * temp = malloc(sizeof(char *));
	char * a = malloc(sizeof(char *));
	int i = 0;	
	do{
		strcpy(temp,"t");
		snprintf(a,sizeof(char *),"%d",i);
		strcat(temp,a);
		printf("Temp created: %s\n", temp);
		i++;
	}while(SymLookUp(myTable,temp)!=NULL);
	SymInsert(myTable,temp,integer);
	return SymLookUp(myTable,temp);
}