/* robotscript.l
 * Lexer (Flex) for RobotScript DSL.
 * Tokenizes keywords, direction words, and numeric literals for the
 * RobotScript grammar defined in robotscript.y.
 */

%{
#include "robotscript.tab.h"
%}

%option noyywrap
%option nounput
%option noinput

%%

"robot"                { return ROBOT; }
"move"                  { return MOVE; }
"turn"                  { return TURN; }
"stop"                  { return STOP; }
"forward"               { return FORWARD; }
"backward"              { return BACKWARD; }
"left"                  { return LEFT; }
"right"                 { return RIGHT; }

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }

[ \t\r\n]+              { /* skip whitespace */ }

.                       {
                            fprintf(stderr,
                                "Lexical Error: unrecognized token '%s'\n",
                                yytext);
                        }

%%
