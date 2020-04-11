%{

/* Declarations section */
#include <stdio.h>
void showToken(char *);

%}

%option yylineno
%option noyywrap
digit   		([0-9])
letter  		([a-zA-Z])
whitespace		([\t\n ])
bin_num         ([01])
oct_num         ([0-7])
hex_digit       ([a-f]|[A-F]|[0-9])

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
(                                               showToken("LPAREN");
)                                               showToken("RPAREN");
{                                               showToken("LBRACE");
}                                               showToken("RBRACE");
[                                               showToken("LBRACKET");
]                                               showToken("RBRACKET");
=                                               showToken("ASSIGN");
0b{bin_num}+                                    showToken("BIN_INT");
0o{oct_num}+                                    showToken("OCT_INT");
((0)|[1-9]{digit}*)                             showToken("DEC_INT");
0x{hex_digit}+                                  showToken("HEX_INT");
{digit}+          			                    showToken("number");
{letter}+					                    showToken("word");
(({digit}+\.{digit}*)|({digit}*\.{digit}+))((e|E)(\+|\-)((0)|[1-9][0-9]*)){0,1}  showToken("DEC_REAL");




{letter}+@{letter}+\.com		                showToken("email address");
{whitespace}				                    ;
.		                                        printf("Lex doesn't know what that is!\n");

%%

void showToken(char * name)
{
        printf("Lex found a %s, the lexeme is %s and its length is %d\n", name, yytext, yyleng);
}
