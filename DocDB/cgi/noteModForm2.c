/**********************************************************************
    noteModForm2.c

    Print the records matched by an msql query.
    Ask which one to modify, calling mcnoteMod2 with the response.

    Glenn Cooper, November 1995
***********************************************************************/

#include "notes.h"

void noteModForm2(MYSQL_RES *result,char *page) {

    int number, num_recs;

    num_recs = mysql_num_rows(result);

    printf("<HTML>");
      printf("<HEAD>");
      printf("<TITLE>Choose an entry to modify</TITLE>");
      printf("%s\n",STYLESHEET);
      printf("</HEAD>");
      printf("<BODY>\n");
      printf("<H1 ALIGN=CENTER>Choose an entry to modify</H1>\n");

      printf("<P>Your search found %d records.  ", num_recs);
      printf("Which one would you like to change?");
      
      printf("<FORM METHOD=POST ACTION=\"/cgi-private/docdb/noteMod2\">");
      printf("Note number: <INPUT SIZE=5 NAME=\"number\"> ");
      printf("<INPUT TYPE=\"submit\" VALUE=\"Submit Query\">");
      printf("</FORM>");
      
      printf("<HR>");
      
      printf("<P>Here are the records your search found:<P>");

      noteSelPrint(result,page);

      printf("</BODY>");
    printf("</HTML>");

return;
}


