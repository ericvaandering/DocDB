/****************************************************************************
    notePrint.c

    Print the matches from an mysql select query to the 
    Notes database.
    The result is stored in result, a struc of type MYSQL_RES.

    The fields in table notes are:

	    0	number		supplied here
	    1	title		user input (or blank)
	    2	authors		user input (or blank)
	    3	pub_info	user input (or blank)
	    4	requestor	user input
	    5	group_name     	user input (or blank)
	    6	class		user input (or blank)
	    7	distribution	user input (or blank)
	    8	doc_type	user input (or blank)
	    9	revision	blank here; user input later
	   11	date_req	supplied here
	   12	date_fil	user input (or blank)
	   13	date_rev	blank here; user input later

    Oct. 1995:  Initial routine  [Glenn Cooper, CDF/Fermilab]
    Jan. 1996:  Modify to handle Julian days, "days since" searches  [GC]
    July 1998:  Adapt for Muon Collider [EB]
    Oct. 2000   Adapt for NUMI notes. Put all expt specific things in .h file
*****************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdlib.h>
#include "notes.h"

#define LABEL_WIDTH 13


int max(v1,v2)
        int     v1,
                v2;
{
        if (v1 > v2)
                return(v1);
        else
                return(v2);
}


fill(length,max,filler)
        int     length,
                max;
        char    filler;
{
        int     count;

        count = max - length;
        while (count-- >= 0)
        {
                printf("%c",filler);
        }
}


void notePrint(MYSQL_RES *result) {

    int off, length;
    int i, indx, j;
    int num_search, num_recs;
    char outstr[MAX_LEN + 50];
    char labels[NUM_FIELDS][LABEL_WIDTH];
    MYSQL_ROW   cur;
    MYSQL_FIELD *curField;

    /* Store field names in array labels */
    strcpy(labels[0],  "Number      ");
    strcpy(labels[1],  "Title       ");
    strcpy(labels[2],  "Authors     ");
    strcpy(labels[3],  "Pub_info    ");
    strcpy(labels[4],  "Requestor   ");
    strcpy(labels[5],  "Group_name  ");
    strcpy(labels[6],  "Class       ");
    strcpy(labels[7],  "Distribution");
    strcpy(labels[8],  "Doc_type    ");
    strcpy(labels[9],  "Revision    ");
    strcpy(labels[10], "Date_req    ");
    strcpy(labels[11], "Date_fil    ");
    strcpy(labels[12], "Date_rev    ");
    strcpy(labels[13], "Upload_type ");


    /* Calling routine should already have output the	*/
    /*    "Content-type: text/html" message		*/

    /***********************************************
    ** Print the returned data
    ************************************************/
    printf("<PRE>");
    while ((cur = mysql_fetch_row(result)))
    {
              /*  printf(" |");  */
              for (off = 0; off < mysql_num_fields(result);off++)
              {
                      curField = mysql_fetch_field(result);
                      switch(curField->type)
                      {
                          case FIELD_TYPE_LONG:
                              length = strlen(curField->name);
                              if (length < 8)
                              {
                                      length = 8;
                              }
                              break;

                          case FIELD_TYPE_DATE:
                              length = strlen(curField->name);
                              if (length < 10)
                              {
                                      length = 10;
                              }
                              break;


                          case FIELD_TYPE_DOUBLE:
                              length = strlen(curField->name);
                              if (length < 12)
                              {
                                      length = 12;
                              }
                              break;

                          case FIELD_TYPE_STRING:
                              length = max(strlen(curField->name),
                                              curField->length);
                              break;
                      }
                      if (cur[off])
                      {
			  /* If record has newlines, use hanging indents */
			  indx = 0;
			  for (i = 0; i < strlen(cur[off]); i++) 
			  {
			      outstr[indx++] = cur[off][i];
			      if (cur[off][i] == '\n') 
			      {
				  for (j = 0; j < LABEL_WIDTH; j++) 
				      outstr[indx++] = ' ';
			      }
			  }
			  outstr[indx++] = '\0';
                          /* printf("%s: %s\n", labels[off], cur[off]); */
                          /* fill(strlen(cur[off]),length,' '); */
                          printf("%s: %s\n", labels[off], outstr);
                      }
                      else
                      {
			  printf("%s:\n", labels[off]);
                              /* printf(" NULL"); */
                              /* fill(4,length,' '); */
                      }
                      /*  printf("|");  */
		      /*  printf(" ");  */
              }
              printf("\n");		/* blank line between records */
              mysql_field_seek(result,0);
    }
    printf("</PRE>");

    /* Add link back to Notes page */
    printf("<BR><BR><A HREF=\"%s/%s\">", NOTES_URL, NOTES_PAGE);
    printf("<IMG ALIGN=middle SRC=\"/icons/back.gif\" ALT=\"*\">");
    printf("Back to %s Notes page</A>",PROJECT_NAME);

    return;
}



