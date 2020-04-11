%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);
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
sign 		    ([-|+])
ascii           (\\u\{({hex_digit}+\})) /* TODO: limit the range 0x20 to 0x7E, 0x09, 0x0A, 0x0D */
escape_char     ([\n|\r|\t|\\|\|{ascii}|\"])

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
id                                              showToken("ID");
dec_real                                        showToken("DEC_REAL");
{hex_num}[p|P]{sign}((0)|[1-9]{digit}*)         showToken("HEX_FP");
"({letter}*{escape_char}*)*"                    showToken("STRING");
comment                                         showToken("COMMENT");






{digit}+          			                    showToken("number");
{letter}+					                    showToken("word");
{letter}+@{letter}+\.com		                showToken("email address");
{whitespace}				                    ;
.		                                        printf("Lex doesn't know what that is!\n");

%%

void showToken(char * name)
{
    printf("Lex found a %s, the lexeme is %s and its length is %d\n", name, yytext, yyleng);
}
