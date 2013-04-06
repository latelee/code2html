 /***********************************************
 *   C语言代码语法高亮工具 
 *编译方法：
 * $ flex code2html.lex
 * $ gcc lex.yy.c -o code2html
 *
 * 使用：
 * $ ./code2html < test.c > test.html
 * 将test.c生成test.html，打开test.html，
 * 复制内容到网页编辑器(即见即所得)中即可。
 * 并不是所有编辑器都支持。
 *
 * log & bug:
        1、注释中多个空格识别不出来。==>在代码中添加对注释空格的处理。
        2、连续2个(或多个)tab键识别不出来。==>暂时用空格代替。
        3、2011-04-21
           尝试不使用blockquote，直接使用div。
           修改显示方式，背景色为浅色，默认字体为黑色。
           添加Makefile，直接make即可生成code2html文件。
        4、2011-04-25
           数字着色问题未解决==>解决
	   修改单词规则：WORD	[a-zA-Z_]+{DIGIT}*，能识别tmp1，数字在前识别不到
        5、为解决数字着色问题，连带一个bug，就是头文件中“.”也被识别为“数字”中的小数点
        6、
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
 /*DEC		(0(\.{DIGIT}+)?)|([1-9]{DIGIT}*(\.{DIGIT}+)?)*/
DEC		[0-9.]+
NUMBER	{HEX}|{OCT}|{DEC}
WORD	[a-zA-Z_]+{DIGIT}*

WHITESPACE	[\t]+
NL		\r?\n
STRING		\"[^"\n]*\"
CHAR		\'[^'\n]*\'
QUOTATION 	{STRING}|{CHAR}

KEYWORD	"while"|"do"|"switch"|"case"|"break"|"default"|"continue"|"for"|"goto"|"if"|"else"|"return"|"typedef"|"sizeof"
TYPE1	"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned"
TYPE2   "struct"|"union"|"enum"|"void"|"const"|"static"|"extern"|"register"|"auto"|"volatile"
TYPE	{TYPE1}|{TYPE2}
PREWORD	"#define"|"#include"|"#error"|"#if"|"#elif"|"#else"|"#ifdef"|"#endif"|"#ifndef"|"#undef"|"#line"|"#pragma"

LINECOMMENT	"//".*\n

%%
"<"	{printf("&lt;");}
">"	{printf("&gt;");}
\t	{printf("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");}
" "	{printf("&nbsp;");}
"&"	{printf("&amp;");}
&nbsp;	{printf("&nbsp;");}

"/*"	{
	char c;
	int done = FALSE;
	printf("<span style=\"color:#008000\">\n");
	ECHO;
	do{
	while ((c=input()) != '*')
	{
		if (c == '\n')
			printf("<br/>\n");
		else if (c == ' ')
			printf("&nbsp;");	/* space in the comment */
		else
			putchar(c);
	}
	putchar(c);
	while((c=input()) == '*')
		putchar(c);
	if (c=='\n')
		printf("<br/>");
	putchar(c);
	if (c == '/')
	{
		done = TRUE;
		
	}
	}while (!done);
	printf("</span>");
}

{LINECOMMENT}		{printf("<span style=\"color:#008000\">%s</span><br/>\n", yytext);}
{QUOTATION}		{printf("<span style=\"color:#ff00ff\">%s</span>", yytext);}
{KEYWORD}|{TYPE}	{printf("<span style=\"color:#0000ff\">%s</span>", yytext);}
{PREWORD}	{printf("<span style=\"color:#0000ff\">%s</span>", yytext);}
{NL}		{printf("<br/>\n");}
{WORD}		{ECHO;}
{NUMBER}	{printf("<span style=\"color:#ff0000\">%s</span>", yytext);}
{WHITESPACE}	{ECHO;}
 /*{WHITESPACE} {printf("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");} */
%%

int main(void)
{
	printf("<html>\n");
	printf("<head>\n");
	printf("</head>\n");
	printf("<body>\n");

#ifdef BACKGROUND_COLOR
	//printf("<blockquote style=\"background-color:#f9f7cc\">\n");
	printf("<div style=\"BORDER-RIGHT: #aaaaaa 1px solid; PADDING-RIGHT: 5px; BORDER-TOP: #aaaaaa 1px solid; PADDING-LEFT: 5px; PADDING-BOTTOM: 5px; BORDER-LEFT: #aaaaaa 1px solid; PADDING-TOP: 5px; BORDER-BOTTOM: #aaaaaa 1px solid; BACKGROUND-COLOR: #dcdcdc\">\n");
#else
	printf("<blockquote>\n");
#endif
	//printf("<!--本语法高亮工具由Late Lee(http://www.latelee.org)使用lex编写-->\n");
	printf("\n<!--this tool is written by Late Lee(http://www.latelee.org) using lex.-->\n\n");

	yylex();

#ifdef BACKGROUND_COLOR
	//printf("</blockquote>\n");
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
