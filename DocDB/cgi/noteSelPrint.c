/****************************************************************************
    noteSelPrint.c

    Print the matches from an mySQL select query to the Notes database.
    The result is stored in result, a struc of type MYSQL_RESULT.

    Oct. 1995:  Initial print routine mcnotePrint  [Glenn Cooper, CDF/Fermilab]
    Dec. 1995:  Modify to match WAIS format, with links to files
		Modify for new cdfnotes DB format for dates
    Mar. 1996:  Install on cdfsga
    Apr. 1996:  Improve formatting of Revision: line,			[GC]
		Print Pub. Info: line only if info exists for that note
		Show file path & name, instead of Postscript: or Abstract:
		Show file sizes
    Jul. 1996:  Get rid of extra &nbsp; in Abstract:  line		[GC]
    Jul. 1998   Modify for MUCOOL notes
    Oct. 2000   Adapt for use by NUMI. Remove expt specific stuff so that
                code can be used for any project with inclusion of 
                appropriate header file.                                [EB}
*****************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <time.h>
#include "notes.h"
#include <string.h>

void Lowercase(char *inString, char *outString) {

    int i, indx;

    /* Make search string case insensitive:  '[Aa][Bb]' etc. */
    indx = 0;
    for (i = 0;  i < strlen(inString);  i++) {
	if (isalpha(inString[i])) {
	    outString[indx++] = tolower(inString[i]);
	}
	else {
	    outString[indx++] = inString[i];
	}
    }

    /* Finally, terminate outString */
    outString[indx] = '\0';

    return;
}


void noteSelPrint(MYSQL_RES *result,char *page) {

    int off, length, len1, len2;
    int i, indx, j, index;
    int num_search, num_recs;
    int ierr1, ierr2;
    int number, nfiles;
    int filesize;
    int filesizes[50];
    char notenum[12];
    char outstr[MAX_LEN + 50];
    char file[128],absfile[128];
    char doc_type[10];
    char upload_type[10];
    char notedir[10];
    char pubdir[128];
    char filename[128];
    char filenames[50][128];
    char distribution[20];
    char link[128];
    char links[50][128];
    MYSQL_ROW   cur;
    MYSQL_FIELD *curField;
    FILE *fp;
    DIR *dirp;
    struct dirent *dp;
    struct stat stbuf;

    int (*compare)();

    compare = strcmp;

    /* Calling routine should already have output the	*/
    /*    "Content-type: text/html" message		*/

    /***********************************************
    ** Print the returned data (based on mysql.c)
    ************************************************/

    printf("<DL>\n");

    while ((cur = mysql_fetch_row(result))) {
	number = atoi(cur[0]);
	/* If necessary, pad Note # with leading zeroes */
	sprintf(notenum, "%.4d", number);
	if (number > 9999) {		/* no support for #'s > 4 digits */
	    printf("<HR>\n");
	    printf("Warning: Note number &gt; 9999 will be truncated. \n");
	    printf("Please contact \n");
	    printf("<A HREF=\"mailto:%s\">%s</A>.\n", REPLY_ADDRESS, 
			REPLY_PERSON);
	    printf("<HR>\n");
	}

	if(cur[1] != NULL && cur[2] != NULL) {


	  /* Print standard info */
	  printf("<DT><LI>\n");

	  /* Check to see that the entry has author and title */

	  printf("<STRONG>Title:</STRONG> %s<BR>\n", cur[1]);
	  printf("<STRONG>Author(s):</STRONG> %s<BR>\n", cur[2]);  
	  printf("<STRONG>%s Note Number:</STRONG> %s-%s-%s-%s<BR>\n", 
		 PROJECT_NAME,NOTE_PREFIX,cur[6], cur[5], notenum);
	  printf("<STRONG>Date Requested:</STRONG> %s<BR>\n",
		  cur[10]);
	  if (strlen(cur[3]) > 0) 
	    printf("<STRONG>Pub. Info:</STRONG> %s<BR>\n", cur[3]);
	  if (cur[11]) {
	    printf("<STRONG>Date Posted:</STRONG> %s<BR>\n",
		   cur[11]);
	  }
	  if (strcmp(cur[9], ""))
	    printf("<STRONG>Revision #:</STRONG> %s &nbsp; &nbsp; ", cur[9]);
	  if (cur[12]) {
	    printf(" <STRONG>Revision date:</STRONG> %s<BR>\n", 
		   cur[12]);
	  }

	  /* Don't print links when on Modify pages */

	  if(strcmp(page,"NOTEMOD")) {

	    /* Check to see if this document has been posted */

	    if (cur[13]) {
	      strcpy(upload_type,cur[13]);

	      /* Construct directory name */
	      strcpy(doc_type,cur[8]);
	      Lowercase(cur[7],distribution);
	      sprintf(notedir, "%s%s", FILE_PREFIX,notenum);
	      sprintf(pubdir, "%s/%s/%s/%s",PUB,distribution,doc_type,notedir);

	      /* If the file type is ps ppt or doc we gzip it */
	      
	      
	      if (!strcmp(doc_type,"ps")) {
		sprintf(file,"%s.%s.gz",notedir,doc_type);
	      }
	      else {
		sprintf(file,"%s.%s",notedir,doc_type);
	      }
	      sprintf(absfile,"%s.txt",notedir);
	      
	      
	      /* Search for this directory - should not get an error here*/
	      
	      dirp = opendir(pubdir);
	      if (dirp == NULL) {
		printf("Error:  could not find directory %s<BR>\n", pubdir);
	      }
	      
	      
	      sprintf(link,"%s/%s/%s/%s/%s", PUB_URL,distribution,doc_type,notedir,absfile);
	      sprintf(filename,"%s/%s",pubdir,absfile);
	      stat(filename, &stbuf);
	      filesize = stbuf.st_size / 1024;
	      
	      printf("Abstract: <A HREF=\"%s\">%s</A>", 
		     link, absfile);
	      printf(" &nbsp; (%d kb)<BR>\n", filesize);
	      
	      sprintf(link,"%s/%s/%s/%s/%s", PUB_URL,distribution,doc_type,notedir,file);
	      sprintf(filename,"%s/%s",pubdir,file);
	      stat(filename, &stbuf);
	      filesize = stbuf.st_size / 1024;
	      
	      printf("Document: <A HREF=\"%s\">%s</A>", 
		     link, file);
	      printf(" &nbsp; (%d kb)<BR>\n", filesize);
	      
	      if (!strcmp(upload_type,"multi") && strcmp(doc_type,"html")) {
		
		/* Look for the rest of the files */
		
		nfiles = 0;
		index = 0;

		while ((dp = readdir(dirp)) != NULL) {
		  if ((strstr(dp->d_name, absfile) == NULL) &&
		      (strstr(dp->d_name, file) == NULL)
		      && strcmp(dp->d_name,".") && strcmp(dp->d_name,"..")) {
		    sprintf(filenames[index], "%s",dp->d_name);
		    index++;
		    nfiles++;
		  }
		}
		
		qsort(filenames,nfiles,128,(*compare));

		for (i=0;i<nfiles;i++) {

		  sprintf(link,"%s/%s/%s/%s/%s", PUB_URL,distribution,doc_type,notedir,filenames[i]);
		  sprintf(filename,"%s/%s",pubdir,filenames[i]);
		  stat(filename, &stbuf);
		  filesize = stbuf.st_size / 1024;
		  printf("File: <A HREF=\"%s\">%s</A>", 
			 link, filenames[i]);
		  printf(" &nbsp; (%d kb)<BR>\n", filesize);
		}
	      }
	      closedir(dirp);
	    }
	  }
	  printf("<P>\n");
	}
	mysql_field_seek(result,0);
    }


    printf("</DL>\n");

    /* Add link back to Notes page */
    printf("<BR><BR><A HREF=\"%s/%s\">", NOTES_URL, NOTES_PAGE);
    printf("<IMG ALIGN=middle SRC=\"/icons/back.gif\" ALT=\"*\">");
    printf("Back to %s Notes page</A>",PROJECT_NAME);

    return;
}




