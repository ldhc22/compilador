/* Luis Daniel Hernández Carrera	A01360411
 * Jesus Torres Vazquez 			A01184899
 *
 * 
 * 
 * 
 *
 */

 #include "FileManagement.h"

 void writeFile(char *file, char *text){
 	FILE *f = fopen(file,"a");
 	if(f==NULL){

 	}else{
 		fprintf(f, "%s\n", text);
 	}
 }

 char * genMult(char * dest, char * arg1, char * arg2){
 	//char * str = strcat(dest,strcat(" mult ",strcat(arg1,arg2))); 	
 	char * str = malloc(sizeof(char *));
 	strcpy(str,dest);
 	strcat(str," mult ");
 	strcat(str,arg1);
 	strcat(str, " ");
 	strcat(str,arg2);
 	return str;
 }

 char * genDiv(char * dest, char * arg1, char * arg2){
 	//char * str = strcat(dest,strcat(" mult ",strcat(arg1,arg2))); 	
 	char * str = malloc(sizeof(char *));
 	strcpy(str,dest);
 	strcat(str," div ");
 	strcat(str,arg1);
 	strcat(str, " ");
 	strcat(str,arg2);
 	return str;
 }

 char * genSum(char * dest, char * arg1, char * arg2){
 	//char * str = strcat(dest,strcat(" mult ",strcat(arg1,arg2))); 	
 	char * str = malloc(sizeof(char *));
 	strcpy(str,dest);
 	strcat(str," sum ");
 	strcat(str,arg1);
 	strcat(str, " ");
 	strcat(str,arg2);
 	return str;
 }

 char * genMinus(char * dest, char * arg1, char * arg2){
 	//char * str = strcat(dest,strcat(" mult ",strcat(arg1,arg2))); 	
 	char * str = malloc(sizeof(char *));
 	strcpy(str,dest);
 	strcat(str," minus ");
 	strcat(str,arg1);
 	strcat(str, " ");
 	strcat(str,arg2);
 	return str;
 }

 char * genAssign(char * dest, char * arg){
 	char * str = malloc(sizeof(char *));
 	strcpy(str,dest);
 	strcat(str," assign ");
 	strcat(str,arg);
 	return str;
 }
