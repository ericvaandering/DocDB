/****************************************************************************
    noteSel.c

    Search notes database to find all entries matching one or more 
       specified string(s), linked by (user-speciified) OR or AND.

    Uses method from NCSA-provided routine post-query.c (which uses 
       routines from util.c) to get input values from stdin.

    Calls routine noteSelPrint to print the results of the mysql query.

    Glenn Cooper, Oct. 1995
    Oct. 2000   Adapt for use by NUMI. Remove expt specific stuff so that
                code can be used for any project with inclusion of 
                appropriate header file.                                [EB}

*****************************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>
#include <string.h>
#include "notes.h"
char *nextword(char *line, char stop) {
    int x=0, xs=0, y=0, z=0;
    char *word = (char *) malloc(sizeof(char) * (strlen(line) + 1));

    for(x=xs;((line[x]) && (line[x] != stop));x++)
        word[z++] = line[x];

    word[z] = '\0';
    if(line[z]) ++z;
    y=0;

    while(line[y++] = line[z++]);
    line += z;
    return word;
}


main(int argc, char *argv[]) {

    /* From routine post-query.c */
    entry entries[MAX_ENTRIES];
    register int x,m=0;
    int cl;

    /* Declarations added by GC */
    MYSQL *db_sock;
    int i, indx, j, ierr;
    int item, n_words,num_recs, num_entries;
    int limit = MAX_DOCS;
    int number;
    char year[4],ndays[4];
    char year_str[14];
    char page[7]="";

    char new_lab[7];
    char buf[2048], pbuf[2048];
    char conj[6], conj_t[6];
    char qtmp[30][5 * MAX_LEN];
    char pqtmp[30][MAX_LEN];
    char glob[5 * MAX_LEN], pglob[MAX_LEN];
    char srchstr[MAX_LEN*2 + 1];
    char linestr[MAX_LEN];
    char words[MAX_WORDS][MAX_LEN],wordsCI[MAX_WORDS][MAX_LEN];
    char *lp, *wp;

    MYSQL_RES *result;
    MYSQL_ROW   cur;
    MYSQL_FIELD *curField;


    /* Set up for html output */
    printf("Content-type: text/html\n\n");

    /* Make sure we're looking at POST method form results */
    if(strcmp(getenv("REQUEST_METHOD"),"POST")) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
        printf("This program should be referenced with a METHOD of POST.\n");
        printf("If you don't understand this, see this ");
	printf("<A HREF=\"%s\">forms overview</A>.\n", FORM_INFO_URL);
	printf("</BODY>\n");
        exit(1);
    }
    if(strcmp(getenv("CONTENT_TYPE"),"application/x-www-form-urlencoded")) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
        printf("This program can only be used to decode form results. \n");
	printf("</BODY>\n");
        exit(1);
    }

    /* Decode form results into individual fields and values */
    cl = atoi(getenv("CONTENT_LENGTH"));
    for(x=0;cl && (!feof(stdin));x++) {
        m=x;
        entries[x].val = fmakeword(stdin,'&',&cl);
        plustospace(entries[x].val);
        unescape_url(entries[x].val);
        entries[x].name = makeword(entries[x].val,'=');
    }
    num_entries = m + 1;


    /*-------------------------------------------------------*/
    /* mSQL-specific part */
    /*-------------------------------------------------------*/

    /* Construct bits of the query string from form inputs */
    item = -1;
    for (i = 0; i < num_entries; i++) {


	/* Initialize default conjunction for words w/in a field */
	sprintf(conj_t, " or ");

	/* First, check for AND or OR selection */
	if (!strcmp(entries[i].name, "conj")) {
	    if (!strcmp(entries[i].val, "or")) {
		sprintf(conj, " or ");
	    }
	    else if (!strcmp(entries[i].val, "and")) {
		sprintf(conj, " and ");
	    }
	}
	else if (!strcmp(entries[i].name, "max_docs")) {
	    if (strcmp(entries[i].val, "")) {
		limit = atoi(entries[i].val);
		if (limit == 0) limit = MAX_DOCS;	/* ck for stray chars */
	    }
	}

	else if (!strcmp(entries[i].name, "title")) {
	  if (strlen(entries[i].val)) {
	    item++;
	    strcpy(linestr,entries[i].val);
	    lp = linestr;
	    for (j = 0; j < MAX_WORDS; j++) {
	      while (lp[0] == ' ') lp++;
	      if (lp[0] == '\0') break;
	      /* check for quoted strings */
	      if ((lp[0] == '\"') || (lp[0] == '\'')) {
		/* special case to handle search for single ' or " */
		if (lp[1] == '\0') {
		  wp = lp;
		  ++lp;
		}
		else {
		  ++lp;
		  wp = nextword(lp, lp[-1]);
		}
	      }
	      else {
		wp = nextword(lp, ' ');
	      }
	      strcpy(words[j], wp);
	      /* Check for special characters, and escape them */
	      mysql_escape_string(srchstr,words[j],strlen(words[j]));
	      /* Make search string case insensitive */
	      mysqlCI(srchstr,wordsCI[j]);
	    }

	    n_words = j;

	    sprintf(qtmp[item], "title like '%%%s%%'",wordsCI[0]);
	    sprintf(pqtmp[item], "title like '%s'", words[0]);
	    for (j = 1; j < n_words; j++) {
	      if (!strcmp(wordsCI[j], "AND")) {
		sprintf(conj_t, " and ");
	      }
	      else if (!strcmp(wordsCI[j], "OR")) {
		sprintf(conj_t, " or ");
	      }
	      else {
		sprintf(qtmp[item], "%s%s title like '%%%s%%'", 
			qtmp[item], conj_t, wordsCI[j]);
		sprintf(pqtmp[item], "%s%s title like '%s'", 
			pqtmp[item], conj_t, words[j]);
		sprintf(conj_t, " or ");
	      }
	    }
	  }
	}
	else if (!strcmp(entries[i].name, "authors")) {
	  if (strlen(entries[i].val)) {
	    item++;
	    strcpy(linestr,entries[i].val);
	    lp = linestr;
	    for (j = 0; j < MAX_WORDS; j++) {
	      while (lp[0] == ' ') lp++;
	      if (lp[0] == '\0') break;
	      /* check for quoted strings */
	      if ((lp[0] == '\"') || (lp[0] == '\'')) {
		/* special case to handle search for single ' or " */
		if (lp[1] == '\0') {
		  wp = lp;
		  ++lp;
		}
		else {
		  ++lp;
		  wp = nextword(lp, lp[-1]);
		}
	      }
	      else {
		wp = nextword(lp, ' ');
	      }
	      strcpy(words[j], wp);
	      /* Check for special characters, and escape them */
	      mysql_escape_string(srchstr,words[j],strlen(words[j]));
	      /* Make search string case insensitive */
	      mysqlCI(srchstr,wordsCI[j]);
	    }

	    n_words = j;
	    sprintf(qtmp[item], "authors like '%%%s%%'", wordsCI[0]);
	    sprintf(pqtmp[item], "authors like '%s'", words[0]);
	    for (j = 1; j < n_words; j++) {
	      if (!strcmp(wordsCI[j], "AND")) {
		sprintf(conj_t, " and ");
	      }
	      else if (!strcmp(wordsCI[j], "AND")) {
		sprintf(conj_t, " or ");
	      }
	      else {
		sprintf(qtmp[item], "%s%s authors like '%%%s%%'", 
			qtmp[item], conj_t, wordsCI[j]);
		sprintf(pqtmp[item], "%s%s authors like '%s'", 
			pqtmp[item], conj_t, words[j]);
		sprintf(conj_t, " or ");
	      }
	    }
	  }
	}
	else if (!strcmp(entries[i].name, "pub_info")) {
	  if (strlen(entries[i].val)) {
	    item++;
	    strcpy(linestr,entries[i].val);
	    lp = linestr;
	    for (j = 0; j < MAX_WORDS; j++) {
	      while (lp[0] == ' ') lp++;
	      if (lp[0] == '\0') break;
	      /* check for quoted strings */
	      if ((lp[0] == '\"') || (lp[0] == '\'')) {
		/* special case to handle search for single ' or " */
		if (lp[1] == '\0') {
		  wp = lp;
		  ++lp;
		}
		else {
		  ++lp;
		  wp = nextword(lp, lp[-1]);
		}
	      }
	      else {
		wp = nextword(lp, ' ');
	      }
	      strcpy(words[j], wp);
	      /* Check for special characters, and escape them */
	      mysql_escape_string(srchstr,words[j],strlen(words[j]));
	      /* Make search string case insensitive */
	      mysqlCI(srchstr,wordsCI[j]);
	    }

	    n_words = j;
	    sprintf(qtmp[item], "pub_info like '%%%s%%'", wordsCI[0]);
	    sprintf(pqtmp[item], "pub_info like '%s'", words[0]);
	    for (j = 1; j < n_words; j++) {
	      if (!strcmp(wordsCI[j], "AND")) {
		sprintf(conj_t, " and ");
	      }
	      else if (!strcmp(wordsCI[j], "OR")) {
		sprintf(conj_t, " or ");
	      }
	      else {
		sprintf(qtmp[item], "%s%s pub_info like '%%%s%%'", 
			qtmp[item], conj_t, wordsCI[j]);
		sprintf(pqtmp[item], "%s%s pub_info like '%s'", 
			pqtmp[item], conj_t, words[j]);
		sprintf(conj_t, " or ");
	      }
	    }
	  }
	}
	else if (!strcmp(entries[i].name, "requestor")) {
	    if (strcmp(entries[i].val, "")) {
		item++;
		/* Check for special characters, and escape them */
		mysql_escape_string(srchstr,entries[i].val,strlen(entries[i].val));
		sprintf(qtmp[item], "requestor like '%%%s%%'", srchstr);
		sprintf(pqtmp[item], "requestor like '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "pt")) {
	    if (strcmp(entries[i].val, "")) {
		/* Check for special characters, and escape them */
		mysql_escape_string(srchstr,entries[i].val,strlen(entries[i].val));
		sprintf(glob, "like '%%%s%%'", srchstr);
		sprintf(pglob, "like '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "group")) {
	    /*
	     * SELECT and RADIO should always send a value, so put in "(any)"
	     * as a default, and then skip it for the query.
	     * (Note that Mosaic & Netscape don't behave as above, but they
	     * should, and this doesn't hurt for them.)
	     */
	    if (strcmp(entries[i].val, "") && strcmp(entries[i].val, "(any)")) {
		
	      item++;
		sprintf(qtmp[item], "group_name like '%%%s%%'", entries[i].val);
		sprintf(pqtmp[item], "group_name = '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "class")) {
	    if (strcmp(entries[i].val, "") && strcmp(entries[i].val, "(any)")) {
		item++;
		sprintf(qtmp[item], "class = '%s'", entries[i].val);
		sprintf(pqtmp[item], "class = '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "distribution")) {
	    if (strcmp(entries[i].val, "") && strcmp(entries[i].val, "(any)")) {
		item++;
		sprintf(qtmp[item], "distribution = '%s'",entries[i].val);
		sprintf(pqtmp[item], "distribution = '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "revision")) {
	    if (strcmp(entries[i].val, "")) {
		item++;
		sprintf(qtmp[item], "revision = '%s'", entries[i].val);
		sprintf(pqtmp[item], "revision = '%s'", entries[i].val);
	    }
	}
	else if (!strcmp(entries[i].name, "number")) {
	    if (strcmp(entries[i].val, "")) {
		if ((number = atoi(entries[i].val)) > 0) {
		    item++;
		    sprintf(qtmp[item], "number = %d", number);
		    sprintf(pqtmp[item], "number = %d", number);
		}
	    }
	}
	else if ((!strcmp(entries[i].name, "date_req_y")) ||
		 (!strcmp(entries[i].name, "date_fil_y")) ||
		 (!strcmp(entries[i].name, "date_rev_y"))) {
	  if (strcmp(entries[i].val, "")) {
	    strcpy(year,entries[i].val);
	    if (!strcmp(entries[i].name,"date_req_y")) {
	      sprintf(year_str,"%s","YEAR(date_req)");
	    }
	    
	    if (!strcmp(entries[i].name,"date_fil_y")) {
	      sprintf(year_str,"%s","YEAR(date_fil)");
	    }
	    
	    if (!strcmp(entries[i].name,"date_rev_y")) {
	      sprintf(year_str,"%s","YEAR(date_rev)");
	    }
	    item++;
	    if (!strcmp(entries[i+1].val, ">")) {
	      sprintf(qtmp[item], 
		      "%s > '%s'", year_str, year);
	      sprintf(pqtmp[item], 
		      "%s > '%s'", year_str, year);
	    }
	    else if (!strcmp(entries[i+1].val, "<")) {
	      sprintf(qtmp[item], 
		      "%s < '%s'", year_str, year);
	      sprintf(pqtmp[item], 
		      "%s < '%s'", year_str, year);
	    }
	    else if (!strcmp(entries[i+1].val, "=")) {
	      sprintf(qtmp[item], 
		      "%s = '%s'", year_str, year);
	      sprintf(pqtmp[item], 
		      "%s = '%s'", year_str, year);
	    }
	  }
	}
	else if ((!strcmp(entries[i].name, "date_req")) ||
		 (!strcmp(entries[i].name, "date_fil")) ||
		 (!strcmp(entries[i].name, "date_rev"))) {
	    if (strcmp(entries[i].val, "")) {
	      strcpy(ndays,entries[i].val);
	      item++;
	      sprintf(qtmp[item], "%s >= DATE_SUB(CURRENT_DATE, INTERVAL %s DAY)", entries[i].name, ndays);
	      sprintf(pqtmp[item], "%s >= DATE_SUB(CURRENT_DATE, INTERVAL %s DAY)", entries[i].name, ndays);
	    }
	}
	else if (!strcmp(entries[i].name, "search_type")) {
	  sprintf(qtmp[item],"distribution = '%s'",entries[i].val);
	    }
	else if (!strcmp(entries[i].name, "search_page")) {
	  strcpy(page,entries[i].val);
	    }
    }

    /* Combine the query bits, using OR or AND as appropriate */
    sprintf(buf, SELECT, TABLE);

    /* Treat global search as special case: */
    if (strcmp(glob, "")) {
	sprintf(buf, "%s title %s", buf, glob);
	sprintf(buf, "%s or authors %s", buf, glob);
	sprintf(buf, "%s or requestor %s", buf, glob);
	sprintf(buf, "%s or pub_info %s", buf, glob);
	sprintf(buf, "%s or group_name %s", buf, glob);
	sprintf(buf, "%s or class %s", buf, glob);
	sprintf(buf, "%s or distribution %s", buf, glob);
	sprintf(pbuf, "%s [any field] %s", pbuf, pglob);
	if (item >= 0) {
	    if (!strcmp(conj, " or ") || !strcmp(conj, " and ")) {
		sprintf(buf, "%s %s ", buf, conj);
		sprintf(pbuf, "%s %s ", pbuf, conj);
	    }
	    else {
		printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
		printf("<BODY>\n<H1>Error</H1><P>\n");
		printf("You must specify AND or OR for a");
		printf("   multiple field search.");
		printf("</BODY>\n");
		exit(-1);
	    }
	}
    }
    else if (item < 0) {
	    printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	    printf("<BODY>\n<H1>Error</H1><P>\n");
	    printf("You didn't specify a query.");
	    printf("</BODY>\n");
	    exit(-1);
    }

    if (item > 0) {
	if (!strcmp(conj, " or ") || !strcmp(conj, " and ")) {
	    sprintf(buf, "%s%s", buf, qtmp[0]);
	    sprintf(pbuf, "%s%s", pbuf, pqtmp[0]);
	    for (i = 1; i <= item; i++) {
		sprintf(buf, "%s%s%s", buf, conj, qtmp[i]);
		sprintf(pbuf, "%s%s%s", pbuf, conj, pqtmp[i]);
	    }
	}
	else {
	    printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	    printf("<BODY>\n<H1>Error</H1><P>\n");
	    printf("You must specify AND or OR for a multiple field search.");
	    printf("</BODY>\n");
	    exit(-1);
	}
    }
    else {		/* (item == 0) */
	sprintf(buf, "%s%s", buf, qtmp[0]);
	sprintf(pbuf, "%s%s", pbuf, pqtmp[0]);
    }

    /* Add "order by" and "limit" clauses */
    sprintf(buf, ORDER, buf, ORDER_FIELD);
    sprintf(buf, LIMIT, buf, limit);


    /* Now do mysql queries */

    db_sock = mysql_init(NULL);
    if (db_sock == NULL) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
        printf ("Error in initializing the database:  %s<P>", mysql_error(db_sock));
	printf("</BODY>\n");
	exit(-1);
    }
     if(mysql_real_connect(db_sock,DBSERVER,USERNAME,PWORD,DB,0,NULL,0) == NULL) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
        printf ("Error in connecting to the database:  %s<P>", mysql_error(db_sock));
	printf("</BODY>\n");
	exit(-1);
    }

    if (mysql_query(db_sock, buf) == -1) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
	printf("The query caused an error:  %s<P>", mysql_error(db_sock));
	printf("Query was: %s<P>", buf);
	printf("</BODY>\n");
	exit(-1);
    }
    result = mysql_store_result(db_sock);
    if (!result) {
	printf("<HEAD>\n<TITLE>Error</TITLE>\n</HEAD>\n");
	printf("<BODY>\n<H1>Error</H1><P>\n");
	printf("Error: query failed.<BR>");
	printf("Query was: %s<P>", buf);
	printf("</BODY>\n");
	exit(-1);
    }

    num_recs = mysql_num_rows(result);


    if (!strcmp(page,"NOTEMOD")) {

      if (num_recs > 1) {
	noteModForm2(result,page);
      }
      else if (num_recs == 1) {
	noteModForm1(result);
      }
      else {
	printf("Sorry, this search did not match any records.<BR>");
	printf("Query was: <STRONG>%s</STRONG><P>", pbuf);
      }

    }
    else {

    /* Format and print the results */

    printf("<HEAD>\n");
    printf("<TITLE>Results of %s Notes Search</TITLE>\n",PROJECT_NAME);
    printf("%s\n",STYLESHEET);
    printf("</HEAD>\n");
    printf("<BODY>\n");
    printf("<H1 ALIGN=CENTER>Results of %s Notes Search</H1>\n",PROJECT_NAME);

    if (num_recs == 1) {
	printf("<font color=\"red\">Your search found the following <STRONG>%d</STRONG>", num_recs);
	printf(" item that matches your query.<BR>\n");
	printf("Query was: <STRONG>%s</STRONG></FONT><P>\n", pbuf);
	noteSelPrint(result,page);
    }
    else if (num_recs > 1) {
	printf("<font color=\"red\">Your search found the following <STRONG>%d</STRONG>", num_recs);
	printf(" items that match your query.<BR>\n");
	printf("Query was: <STRONG>%s</STRONG></FONT><BR>\n", pbuf);
	noteSelPrint(result,page);
    }
    else {
	printf("Sorry, this search did not match any records.<BR>");
	printf("Query was: <STRONG>%s</STRONG><P>", pbuf);
    }


    /* Close HTML output */
    printf("</BODY>");

    }

    /* Free memory used for query result, and disconnect socket */
    mysql_free_result(result);
    mysql_close(db_sock);

    return;
}


/********** routines included from NCSA file util.c ********************/

char *makeword(char *line, char stop) {
    int x = 0,y;
    char *word = (char *) malloc(sizeof(char) * (strlen(line) + 1));

    for(x=0;((line[x]) && (line[x] != stop));x++)
        word[x] = line[x];

    word[x] = '\0';
    if(line[x]) ++x;
    y=0;

    while(line[y++] = line[x++]);
    return word;
}

char *fmakeword(FILE *f, char stop, int *cl) {
    int wsize;
    char *word;
    int ll;

    wsize = 102400;
    ll=0;
    word = (char *) malloc(sizeof(char) * (wsize + 1));

    while(1) {
        word[ll] = (char)fgetc(f);
        if(ll==wsize) {
            word[ll+1] = '\0';
            wsize+=102400;
            word = (char *)realloc(word,sizeof(char)*(wsize+1));
        }
        --(*cl);
        if((word[ll] == stop) || (feof(f)) || (!(*cl))) {
            if(word[ll] != stop) ll++;
            word[ll] = '\0';
	    word = (char *) realloc(word, ll+1);
            return word;
        }
        ++ll;
    }
}

char x2c(char *what) {
    register char digit;

    digit = (what[0] >= 'A' ? ((what[0] & 0xdf) - 'A')+10 : (what[0] - '0'));
    digit *= 16;
    digit += (what[1] >= 'A' ? ((what[1] & 0xdf) - 'A')+10 : (what[1] - '0'));
    return(digit);
}

void unescape_url(char *url) {
    register int x,y;

    for(x=0,y=0;url[y];++x,++y) {
        if((url[x] = url[y]) == '%') {
            url[x] = x2c(&url[y+1]);
            y+=2;
        }
    }
    url[x] = '\0';
}

void plustospace(char *str) {
    register int x;

    for(x=0;str[x];x++) if(str[x] == '+') str[x] = ' ';
}

char *strip_quotes(char *twords, int n_words) {

}
