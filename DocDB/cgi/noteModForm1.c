/*****************************************************************************
    noteModForm1.c

    Enter the record matched by an mysql query into an HTML form, 
	for user changes and input to noteMod1.c.

    Mov. 1995:  Initial routine			[Glenn Cooper, CDF/Fermilab]
    Dec. 1995:  Revise to account for 3 date_req fields			[GC]
    May  1996:  Correct field lengths to agree with database		[GC]
    Jul. 1996:  Fixed bug with length alloc. for title (80 -> 100)	[GC]
    June 1997:  Correct spelling, PLUG_UPG to PLUG_UPGR			[GC]
    Oct  2000:  Adapt for NuMI. Cleanup and put expt specific stuff into
                notes.h as much as possible                             [EB]
******************************************************************************/

#include "notes.h"
#include <strings.h>

void noteModForm1(MYSQL_RES *result) {

    int number,i,j,num_groups,match;
    char title[256];
    char authors[256];
    char pub_info[256];
    char requestor[51];
    char group[NUM_GROUPS][21], class[11], distribution[11];
    char temp[NUM_GROUPS*21];
    char file_name[101];
    char revision[11];
    char date_req[11];
    char date_fil[11]="";
    char date_rev[11]="";
    char delim[]=",";
    char *word;

    MYSQL_ROW   cur;
    MYSQL_FIELD *curField;
    int num_fields;

    /* Copy fields from result into named variables */
    if ((num_fields = mysql_num_fields(result)) != NUM_FIELDS) {
	printf("Sorry, I don't understand an input with %d fields<BR>", 
		num_fields);
	return;
    }

    cur = mysql_fetch_row(result);
    number = atoi(cur[0]);
    strcpy(title, cur[1]);
    strcpy(authors, cur[2]);
    strcpy(pub_info, cur[3]);
    strcpy(requestor, cur[4]);
    strcpy(temp, cur[5]);
    strcpy(class, cur[6]);
    strcpy(distribution, cur[7]);
    strcpy(file_name, cur[8]);
    strcpy(revision, cur[9]);
    strcpy(date_req,cur[10]);
    if (cur[11] != NULL) 
      strcpy(date_fil,cur[11]);
    if (cur[12] != NULL) 
      strcpy(date_rev,cur[12]);

    /* Split up group into list of words */

    num_groups=0;
    word = strtok(temp,delim);
    strcpy(group[num_groups],word);
    
     while (word != NULL) {
       num_groups++;
       word = strtok(NULL,delim);
       if(word != NULL) {
	 strcpy(group[num_groups],word);
       }
     }

    /* Print HTML header and user instructions */
    printf("<HTML>");
    printf("<HEAD>");
    printf("<TITLE>Modify %s Note #%d</TITLE>", PROJECT_NAME,number);
    printf("</HEAD>");
    printf("%s\n",STYLESHEET);
    printf("<BODY>");
    printf("<H1>Modify %s Note #%d</H1>", PROJECT_NAME,number);

    printf("<P> Make the changes you wish, then press the SUBMIT button.");

    printf("<HR>");

    printf("<FORM METHOD=POST ACTION=\"/cgi-private/docdb/noteMod1\">");

    printf("<P><INPUT TYPE=\"submit\" VALUE=\"Submit changes\">");
    printf("   <INPUT TYPE=\"reset\" VALUE=\"Clear form\"><P>");

    printf("Note number: <STRONG>%d</STRONG><P>", number);
    printf("<INPUT TYPE=HIDDEN NAME=\"number\" VALUE=\"%d\">", number);

    printf("<DL>");

    printf("<DT>Title:");
    printf("<DD><INPUT SIZE=70 MAXLENGTH=99 NAME=\"title\" VALUE=\"%s\">", 
		title);

    printf("<DT>Authors:");
    printf("<DD><TEXTAREA ROWS=3 COLS=70 NAME=\"authors\">%s</TEXTAREA>", 
		authors);

    printf("<DT>Publication info:");
    printf("<DD><TEXTAREA ROWS=2 COLS=70 NAME=\"pub_info\">%s</TEXTAREA>", 
		pub_info);

    printf("<DT>Date requested:");
    printf("<DD><INPUT SIZE=11 NAME=\"date_req\" VALUE=\"%s\">", 
		date_req);

    printf("<DT>Date posted:");
    if (strcmp(date_fil,"") != 0) {
	printf("<DD><INPUT SIZE=11 NAME=\"date_fil\" VALUE=\"%s\">",
			date_fil);
    }
    else {
	printf("<DD><INPUT SIZE=11 NAME=\"date_fil\">");
    }

    printf("<P>");
    printf("<DT>Category:");

    printf("<DD><SELECT SIZE=10 NAME=\"group\" MULTIPLE>");
      for (i=0;i < NUM_CATS; i++) {
	 for (j=0;j<num_groups+1;j++) {
	  if (strcmp(opt_name[i],group[j]) == 0){
	    printf("%s",opt_str_sel[i]);
	    match = i;
	    break;
	  }
	 }
	 for (j=0;j<num_groups+1;j++) {
	   if (strcmp(opt_name[i],group[j]) != 0 && match != i) {
	     printf("%s",opt_str[i]);
	     break;
	  }
	}
      }
    printf("</SELECT>");

    printf("<P>");
    printf("<DT>Note Classsification:");
    printf("<DD>");
    for (i=0;i < NUM_CLASS;i++) {
      if (strcmp(class_name[i],class) == 0)
	printf("%s",class_str_check[i]);
      else 
	printf("%s",class_str[i]);
    }


    printf("<DT>Distribution: ");
    printf("<DD>");
    if (strcmp("PUBLIC",distribution) == 0)
	printf("<INPUT TYPE=\"radio\" NAME=\"distribution\" VALUE=\"PUBLIC\" CHECKED> PUBLIC");
    else
	printf("<INPUT TYPE=\"radio\" NAME=\"distribution\" VALUE=\"PUBLIC\"> PUBLIC");

    if (strcmp("RESTRICTED",distribution) == 0)
	printf("<INPUT TYPE=\"radio\" NAME=\"distribution\" VALUE=\"RESTRICTED\" CHECKED> RESTRICTED");
    else
	printf("<INPUT TYPE=\"radio\" NAME=\"distribution\" VALUE=\"RESTRICTED\"> RESTRICTED");

    printf("<P>");
    printf("<DT>File name:");
    printf("<DD><INPUT SIZE=70 NAME=\"file_name\" VALUE=\"%s\">", 
			file_name);

    printf("<DT>Requestor:");
    printf("<DD><INPUT SIZE=70 NAME=\"requestor\" VALUE=\"%s\">", 
			requestor);

    printf("<DT>Revision #:");
    printf("<DD><INPUT SIZE=4 NAME=\"revision\" VALUE=\"%s\">", 
			revision);

     printf("<DT>Date revised:");
     if (strcmp(date_rev,"") != 0) {
       printf("<DD><INPUT SIZE=11 NAME=\"date_rev\" VALUE=\"%s\">",
	      date_rev);
     }
     else {
       printf("<DD><INPUT SIZE=11 NAME=\"date_rev\">");
     }

    printf("</DL>");

    printf("<P><INPUT TYPE=\"submit\" VALUE=\"Submit changes\">");
    printf("   <INPUT TYPE=\"reset\" VALUE=\"Clear form\">");

    printf("</FORM>");

    /* Add link back to Notes page */
    printf("<P><A HREF=\"%s/%s\">", NOTES_URL, NOTES_PAGE);
    printf("<IMG ALIGN=middle SRC=\"/icons/back.gif\" ALT=\"*\">");
    printf("Back to BTeV Documents page</A>");

    printf("</BODY>");
    printf("</HTML>");

return;
}





