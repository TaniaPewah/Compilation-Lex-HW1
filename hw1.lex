%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);
void toLower(char *);
void handleString();
char ascii_buffer[6];
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
ascii          ((\\u\{({hex_digit})+\}))
escape_char     ([\n|\r|\t|\\|{ascii}|\"])
printable_char  ([\x20-\x7E])


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
((\/\*)(([^\*])|(\*([^\/])))*(\*\/))|(\/\/.*)                showToken("COMMENT");
((\/\*)(([^\*])|(\*([^\/])))*)                  showToken("OPEN_COMMENT");
==|!=|<|>|<=|>=                                 showToken("RELOP");
&&|\|\|                                         showToken("LOGOP");
\+|\-|\*|\/|%                                   showToken("BINOP");
true                                            showToken("TRUE");
false                                           showToken("FALSE");
->                                              showToken("ARROW");
:                                               showToken("COLON");
0b{bin_digit}+                                  showToken("BIN_INT");
0o{oct_digit}+                                  showToken("OCT_INT");
((0)|[1-9]{digit}*)                             showToken("DEC_INT");
{hex_num}                                       showToken("HEX_INT");
_({letter}|{digit})+|({letter}|{digit})+        showToken("ID");
(({digit}+\.{digit}*)|({digit}*\.{digit}+))((e|E){sign}((0)|[1-9]{digit}*)){0,1}           showToken("DEC_REAL");
{hex_num}[p|P]{sign}((0)|[1-9]{digit}*)         showToken("HEX_FP");

\"(({printable_char})|([[:space:]]|\n|\r|\t|\\|\"|{ascii}))*\"                     handleString();
{ascii}                                         showToken("ASCII");


{whitespace}				                    ;
.		                                        printf("Lex doesn't know what that is!\n");

%%

void showToken(char * name)
{
    printf("%d %s %s\n", yylineno, name, yytext);
}

void handleString(){

    int new_lengh = 0;
    int tmp;
    char* buffer_ptr;
    memset(string_buffer, 0, strlen(string_buffer));
    buffer_ptr = string_buffer;
    if (*(yytext++) == '\"'){ // Double quote string

        while (*yytext != '\"') { // While not end of string

            *(buffer_ptr++)= *(yytext++);
            printf("buffer ptr %c yytext %c\n", *(buffer_ptr - 1), *(yytext));
            new_lengh++;
        }
        yytext = string_buffer; // Set new yytext after change
        yyleng = new_lengh; // Update new length of yytext
        yytext[new_lengh] = '\0';
    }

    printf("%d STRING %s\n", yylineno, yytext);
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
