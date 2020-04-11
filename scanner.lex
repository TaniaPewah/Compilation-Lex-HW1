%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);

%}

%option yylineno
%option noyywrap
digit   		([0-9])
letter  		([a-zA-Z])
whitespace		([\t\r\n ])
bin_num         ([01])
oct_num         ([0-7])
hex_digit         ([a-f]|[A-F]|[0-9])

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
0b{bin_num}+                                    showToken("BIN_INT");
0o{oct_num}+                                    showToken("OCT_INT");
((0)|[1-9]{digit}*)                             showToken("DEC_INT");
0x(hex_digit)+                                  showToken("HEX_INT");
id                                              showToken("ID");
dec_real                                        showToken("DEC_REAL");
hex_fp                                          showToken("HEX_FP");
stringg                                         showToken("STRING");
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
