 /****************************************************************************
 *   linux脚本、提示信息语法高亮工具 
 * 编译方法：
 * $ flex config2html.lex
 * $ gcc lex.yy.c -o config2html
 *
 * 使用：
 * $ ./config2html < shell.sh > test.html
 * 将shell.sh生成test.html，打开test.html，
 * 复制内容到网页编辑器(即见即所得)中即可。
 * 并不是所有编辑器都支持。
 *
 * 
 * log & bug:
        1、root提示符为“#”，一般注释亦为“#”，前者在前面加“]”
           以适合于[root@FightNow]# 的情况。
        2、2011-04-21
           尝试不使用blockquote，直接使用div。
           修改显示方式，配置成Linux终端颜色，默认字体为白色。
           添加Makefile，直接make即可生成config2html文件。
        3、数字着色问题未解决
        4、
        5、	
 ****************************************************************************/

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
 /*DEC		(0(\.{DIGIT}+)?)|([1-9]{DIGIT}*(\.{DIGIT}+)?) */
DEC	([1-9]{DIGIT}*(\.{DIGIT}+)?)
 /*NUMBER	{DEC}|{OCT}|{HEX} */
NUMBER	{DEC} | {OCT} | {HEX}

WORD		[a-zA-Z0-9_\.]+
WHITESPACE	[\t]+
NL			\r?\n
 /* "foo" 'f' `command` */
STRING		\"[^"\n]*\"
CHAR		\'[^'\n]*\'
COMMAND		\`[^`\n]*\`
QUOTATION 	{STRING}|{CHAR}

 /* $(foo) ${foo} $foo $1 */
MACRO1	\$\({WORD}*\)
MACRO2	\$\{{WORD}\}|\$\{{DIGIT}\}
MACRO3	\${WORD}|\${DIGIT}
MACRO	{MACRO1}|{MACRO2}|{MACRO3}

LINE	("$ ".*)|("]# ".*)
RUN	"./".*
ME		"latelee"|"FightNow"|"FIghtNow!"|"Late Lee"
KEYWORD1	"if"|"else"|"elif"|"then"|"fi"
KEYWORD2	"case"|"in"|"esac"|"return"
KEYWORD3	"select"|"in"|"do"|"break"|"done"|"for"|"while"
KEYWORD4	"YES"|"NO"|"yes"|"no"|(\%{WORD})
KEYWORD		{KEYWORD1}|{KEYWORD2}|{KEYWORD3}|{KEYWORD4}

BRACKET	"[".*\]
PATH	("/".*[ ])|("/".*)
%%
"<"	{printf("&lt;");}
">"	{printf("&gt;");}
\t	{printf("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");}
" "	{printf("&nbsp;");}
"&"	{printf("&amp;");}
&nbsp;	{printf("&nbsp;");}

"#"|";"	{
	char c;
	printf("<span style=\"color:#008000\">\n");
	ECHO;

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
	}
}

{QUOTATION}		{printf("<span style=\"color:#ff00ff\">%s</span>", yytext);}
{KEYWORD}		{printf("<span style=\"color:#0000ff\">%s</span>", yytext);}
{BRACKET}		{printf("<span style=\"color:#6600ff\">%s</span>", yytext);}
{COMMAND}|{PATH}|{RUN}		{printf("<span style=\"color:#6600ff\">%s</span>", yytext);}
 /*{LINE}			{printf("<span style=\"font-weight:bold\">%s</span>", yytext);} */
 /*{LINE}			{printf("<span>%s</span>", yytext);} */
{ME}			{printf("<span style=\"color:#ff0000;font-weight:bold\">%s</span>", yytext);}
{NL}			{printf("<br/>\n");}
{WORD}			{ECHO;}
{HEX}		{printf("<span style=\"color:#ff0000\">%s</span>", yytext);}
{WHITESPACE}	{ECHO;}

%%

int main(void)
{
	printf("<html>\n");
	printf("<head>\n");
	printf("</head>\n");
	printf("<body>\n");

#ifdef BACKGROUND_COLOR
	//printf("<blockquote style=\"background-color:#c4c4e1\">\n");
	printf("<div style=\"BORDER-RIGHT: #aaaaaa 1px solid; PADDING-RIGHT: 5px; BORDER-TOP: #aaaaaa 1px solid; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; BORDER-LEFT: #aaaaaa 1px solid; PADDING-TOP: 5px; BORDER-BOTTOM: #aaaaaa 1px solid; BACKGROUND-COLOR: #000000\">\n");
	printf("<font color=#fffafa>\n");
#else
	printf("<blockquote>\n");
#endif
	//printf("<!--本语法高亮工具由Late Lee(http://www.latelee.org)使用lex编写-->\n");
	printf("\n<!--this tool is written by Late Lee(http://www.latelee.org) using lex.-->\n\n");

	yylex();

#ifdef BACKGROUND_COLOR
	//printf("</blockquote>\n");
	printf("</font>");
	printf("</div>\n");
#else
	printf("</blockquote>\n");
#endif
	printf("</body>\n");
	printf("</html>\n");
}

int yywrap()
{
	return 1;
}
