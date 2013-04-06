 /***********************************************
 *   linux Makefile语法高亮工具 
 * 编译方法：
 * $ flex make2html.lex
 * $ gcc lex.yy.c -o make2html
 *
 * 使用：
 * $ ./make2html < Makefile > test.html
 * 将Makefile生成test.html，打开test.html，
 * 复制内容到网页编辑器中即可。
 **********************************************/

%{
#include <stdio.h>
#define FALSE 0
#define TRUE 1
int yywrap();
%}

DIGIT	[0-9]
XDIGIT	[0-9a-fA-f]
ODIGIT	[0-7]
HEX		0(x|X){XDIGIT}+
OCT		0{ODIGIT}+
DEC		(0(\.{DIGIT}+)?)|([1-9]{DIGIT}*(\.{DIGIT}+)?)
NUMBER	{HEX}|{OCT}|{DEC}

WORD		[a-zA-Z0-9_]+
WHITESPACE	[\t]+
NL			\r?\n
STRING		\"[^"\n]*\"
CHAR		\'[^'\n]*\'
COMMAND		\`[^`\n]*\`
QUOTATION 	{STRING}|{CHAR}

 /* $(foo) ${foo} $foo $1 */
MACRO1	\$\({WORD}*\)
 /*MACRO1	\$\(.*[^\)]\)$*/
MACRO2	\$\{{WORD}\}|\$\{{DIGIT}\}
MACRO3	\${WORD}|\${DIGIT}
MACRO4	"$@"|"$<"|"$^"|"$?"|"$+"|"$*"|"$%"
MACRO	{MACRO1}|{MACRO2}|{MACRO3}|{MACRO4}

CMD_MAKEFILE		@({WORD})
KEYWORD_MAKEFILE	"ifeq"|"ifneq"|"endif"
TARGET_MAKEFILE	({WORD}[\:][\n])

KEYWORD1	"if"|"else"|"elif"|"then"|"fi"
KEYWORD2	"case"|"in"|"esac"|"return"
KEYWORD3	"select"|"in"|"do"|"break"|"done"|"for"|"while"
KEYWORD		{KEYWORD1}|{KEYWORD2}|{KEYWORD3}|{KEYWORD_MAKEFILE}

%%
"<"	{printf("&lt;");}
">"	{printf("&gt;");}
\t	{printf("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");}
" "	{printf("&nbsp;");}
"&"	{printf("&amp;");}
&nbsp;	{printf("&nbsp;");}

"#"	{
	char c;
	int done;
	printf("<span style=\"color:#008000\">\n");
	done = FALSE;
	ECHO;
	do{
	while ((c=input()) != '\n')
	{
		if (c == ' ')
			printf("&nbsp;");	/* space in the comment */
		else
			putchar(c);
	}
	if (c == '\n')
	{
			printf("</span>\n");
			printf("<br/>\n");
			done=TRUE;
	}
	} while (!done);
}

{QUOTATION}			{printf("<span style=\"color:#ff00ff\">%s</span>", yytext);}
{KEYWORD}|{CMD_MAKEFILE}	{printf("<span style=\"color:#0000ff\">%s</span>", yytext);}
{MACRO}				{printf("<span style=\"color:#ff8000; font-weight:bold\">%s</span>", yytext);}
{TARGET_MAKEFILE}		{printf("<span style=\"color:#660066\">%s</span><br />\n", yytext);}
{COMMAND}			{printf("<span style=\"color:#6600ff\">%s</span>", yytext);}
{NL}		{printf("<br/>\n");}
{WORD}		{ECHO;}
{NUMBER}	{ECHO;}
{WHITESPACE}	{ECHO;}

%%

int main(void)
{
	printf("<html>\n");
	printf("<head>\n");
	printf("</head>\n");
	printf("<body>\n");
#ifdef BACKGROUND_COLOR
	printf("<blockquote style=\"background-color:#ffddbd\">\n");
#else
	printf("<blockquote>\n");
#endif
	//printf("<!--本语法高亮工具由Late Lee(http://www.latelee.org)使用lex编写-->\n");
	printf("\n<!--this tool is written by Late Lee(http://www.latelee.org) using lex.-->\n\n");

	yylex();

	printf("</blockquote>\n");
	printf("</body>\n");
	printf("</html>\n");
}

int yywrap()
{
	return 1;
}
