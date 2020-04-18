%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);
void toLower(char *);
void handleString();
void handleUnclosedString();
void handleComment();
void unclose_comment();
int power(int, int);
int getDecValue(int);
void fromHexToDec();
void fromBinToDec();
void fromOctToDec();
int isHex(char);
void showDecInt();
int isAsciiValid(char*);
void handleGeneralError();
int maxAsciBuffer = 6;
char ascii_buffer[maxAsciBuffer];
char string_buffer[1024];

%}

%option yylineno
%option noyywrap
digit   		([0-9])
letter  		([a-zA-Z])

whitespace		([\t\r\n ])
bin_digit       ([01])
oct_digit       ([0-7])
hex_digit       ([a-f]|[A-F]|[0-9])
hex_num         (0x({hex_digit})+)
sign 		    ([\-|\+])
/* TODO: limit the range 0x20 to 0x7E, 0x09, 0x0A, 0x0D */
ascii          (\\u\{({hex_digit}{hex_digit})\})
printable_char  ([\x20-\x7E])
printable_char_first [\x20-\x21]
printable_char_rest [\x23-\x7E]




%%
Int|UInt|Double|Float|Bool|String|Character     showToken("TYPE");

var                                             showToken("VAR");
let                                             showToken("LET");
func                                            showToken("FUNC");
import                                          showToken("IMPORT");
nil                                             showToken("NIL");
while                                           showToken("WHILE");
if                                              showToken("IF");
else                                            showToken("ELSE");
return                                          showToken("RETURN");

;                                               showToken("SC");
,                                               showToken("COMMA");
\(                                               showToken("LPAREN");
\)                                               showToken("RPAREN");
\{                                               showToken("LBRACE");
\}                                               showToken("RBRACE");
\[                                               showToken("LBRACKET");
\]                                               showToken("RBRACKET");
=                                               showToken("ASSIGN");
((\/\*)(([\x20-\x29]|[\x2B-\x7E]|{whitespace})|(\*([\x20-\x2E]|[\x30-\x7E]|{whitespace})))*(\*\/))|(\/\/{printable_char}*)   handleComment();
(\/\*)(([\x20-\x29]|[\x2B-\x7E]|{whitespace})|(\*([\x20-\x2E]|[\x30-\x7E]|{whitespace})))*                  unclose_comment();
==|!=|<|>|<=|>=                                 showToken("RELOP");
&&|\|\|                                         showToken("LOGOP");
\+|\-|\*|\/|%                                   showToken("BINOP");
true                                            showToken("TRUE");
false                                           showToken("FALSE");
->                                              showToken("ARROW");
:                                               showToken("COLON");
0b{bin_digit}+                                  fromBinToDec();
0o{oct_digit}+                                  fromOctToDec();
{digit}*                                        showDecInt();
{hex_num}                                       fromHexToDec();
(_({letter}|{digit})+)|({letter}({letter}|{digit})*)        showToken("ID");
(({digit}+\.{digit}*)|({digit}*\.{digit}+))((e|E){sign}({digit}*)){0,1}          showToken("DEC_REAL");
{hex_num}[p|P]{sign}({digit}*)                  showToken("HEX_FP");
\"((\\\")|[^\"])*\"                             handleString();
\"((\\\")|[^\"\n])*                             handleUnclosedString();
{whitespace}				                    ;
.		                                        handleGeneralError();

%%

void showToken(char * name)
{
    printf("%d %s %s\n", yylineno, name, yytext);
}

void showDecInt(){
    int decInt = atoi(yytext);
    printf("%d DEC_INT %d\n", yylineno, decInt);
}

void handleUnclosedString(){
    int i = 0;

    while(i < yyleng){
        if(((int)*yytext < 32 && (int)*yytext != 9 && (int)*yytext != 10 && (int)*yytext != 13) || ((int)*yytext > 126)){
            printf("Error %c\n", *yytext);
            exit(0);
        }
        *(yytext++);
        i++;

    }
    printf("Error unclosed string\n");
    exit(0);
}

void handleString(){

    int new_lengh = 0;
    int tmp;
    char buffer_ptr[1024];
    int index = 0;

    if (*(yytext++) == '\"'){ // Double quote string

        while (*yytext != '\"') { // While not end of string

            if(((int)*yytext < 32 && (int)*yytext != 9 && (int)*yytext != 10 && (int)*yytext != 13) || ((int)*yytext > 126)){
                printf("Error %c\n", *yytext);
                exit(0);
            }

            if ( *yytext == '\n'){
                printf("Error unclosed string\n");
                exit(0);
            }

            if ( *yytext == '\\'){

                switch(*(++yytext)){
                case 'n':
                    buffer_ptr[index++] = '\n';
                    break;
                case 't':
                    buffer_ptr[index++] = '\t';
                    break;
                case 'r':
                    buffer_ptr[index++] = '\r';
                    break;
                case '"':
                    buffer_ptr[index++] = '"';
                    break;
                case '\\':
                    buffer_ptr[index++] = '\\';
                    break;
                case 'u':
                    if(isAsciiValid(yytext)){

                        //printf("ascii %s \n",  ascii_buffer);

                        // decode
                        toLower(ascii_buffer);
                        tmp = (int)strtol(ascii_buffer, NULL, 16);
                        //printf("strtol %d \n",  tmp);

                        *(yytext++);
                        *(yytext++);
                        *(yytext++);
                        *(yytext++);

                        if (tmp >= 32 && tmp <= 126){ // If printable ascii
                            buffer_ptr[index++] = (char)tmp;
                        }
                        else{
                            printf("Error undefined escape sequence u\n");
                            exit(0);
                        }
                    }
                    else{
                        printf("Error undefined escape sequence u\n");
                        exit(0);
                    }
                    break;
                default :
                    printf("Error undefined escape sequence %c\n", *yytext);
                    exit(0);
                    break;
                }
            } else {
                buffer_ptr[index++] = *yytext;
            }

            // printf("%c",  buffer_ptr[index-1]);
            *(yytext++);
        }

        buffer_ptr[index] = '\0';
    }
    //printf("\n");

    printf("%d STRING %s\n", yylineno, buffer_ptr);
}

void toLower(char* s) {
	char* ptr = s;
	while (*ptr) {
		if( *ptr >= 'A' && *ptr <= 'Z') {
			*ptr = (*ptr - 'A') + 'a';
		}
		ptr++;
	}
}

void handleComment() {
    char* buffer_ptr = yytext;
    int comment_len = yyleng;
    int num_lines = 1;

    for(int i = 1; i < comment_len - 1; i++) {
        if (buffer_ptr[i] == '/' && buffer_ptr[i + 1] == '*') {
            printf("Warning nested comment\n");
            exit(0);
        }
    }

    for(int i = 0; i < comment_len; i++) {
        if (buffer_ptr[i] == '\n') {
            num_lines++;
        }
    }
    printf("%d COMMENT %d\n", yylineno, num_lines);
}

void unclose_comment(){
    printf("Error unclosed comment\n");
    exit(0);
}

int power(int base, int exp){
    int value = 1;
    for(int i = exp; i > 0; i--){
        value *= base;
    }
    return value;
}


int getDecValue(int base){
    char* new_num;
    int dec_value = 0, exp = 0, current_lsb = 0;

    *(yytext++);
    *(yytext++);
    
    new_num = yytext;

    // printf("new num is: %s\nIt's length is %d\n", new_num, yyleng - 2);
    toLower(new_num);

    for(int i = yyleng - 3; i >= 0; i--){
        if(new_num[i] >= 'a'){
            current_lsb =  (int)(new_num[i] - 'a' + 10);
        }
        else{
            current_lsb =  (int)(new_num[i] - '0');
        }

        dec_value += power(base, exp) *  current_lsb;
        // printf("Current dec_value = %d\n power is = %d\ncurrent lsb = %d\n", dec_value, power(base, exp), current_lsb);
        exp++;
    }
    return dec_value;
}


void fromHexToDec(){
    int dec_value = getDecValue(16);
    printf("%d HEX_INT %d\n", yylineno, dec_value);
}


void fromOctToDec(){
    int dec_value = getDecValue(8);
    printf("%d OCT_INT %d\n", yylineno, dec_value);
}


void fromBinToDec(){
    int dec_value = getDecValue(2);
    printf("%d BIN_INT %d\n", yylineno, dec_value);
}


int isAsciiValid(char* asciText){

    int counter = 0;
    asciText++;
    if( asciText[0] == '{'){
        asciText++;

        while(asciText[0] != '}' && (counter < maxAsciBuffer) && isHex(asciText[0]) ) {
            ascii_buffer[counter] = asciText[0];
            counter++;
            asciText++;
        }

        ascii_buffer[counter] = '\0';

        if(asciText[0] != '}'){
            return false;
        }
    }
    else {
        return false;
    }

    return true;
}

int isHex(char c){
	return  ( (c >= '0' && c <= '9') // digit
		   || (c >= 'a' && c <= 'f') // lowercase hex
		   || (c >= 'A' && c <= 'F'));
}

void handleGeneralError(){
    printf("Error %s\n", yytext);
    exit(0);
}

