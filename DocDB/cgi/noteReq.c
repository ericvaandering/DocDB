/*****************************************************************************
    noteReq.c

    Assigns the next unused number for a new Note, with fields filled 
    in by the user on the WWW page.
    The fields in table notes are:

	    0	number		supplied here
	    1	title		user input (or blank)
	    2	authors		user input (or blank)
	    3	pub_info	user input (or blank)
	    4	requestor	user input
	    5	group_name	user input - mutiple entries allowed (or blank)
	    6	class		user input (or blank)
	    7	distribution	user input (or blank)
	    8	file_name	user input (or blank)
	    9	revision	blank here; user input later
	   10	date_req	supplied here
	   11	date_fil	user input (or blank)
	   12	date_rev	blank here; user input later

    Gets the last Note number assigned from the notes entry in table 
    MAXINDEX, increments the value stored there, and assigns the incremented 
    value as the number for the requested Note.

    Assigns the current date as the "Date requested".

    Uses method from NCSA-provided routine post-query.c (which uses routines 
    from util.c) to get input values from QUERY_STRING environment variable.

    Oct. 1995:  Initial working script		[Glenn Cooper, CDF/Fermilab]
    Dec. 1995:  Modify to follow standard form layout, and to use	[GC]
		  numerical date (requested, filed, revised) fields
    Jan. 1996:  Add Julian day fields					[GC]
    May  1996:  Correct field lengths to agree with database		[GC]
    July 1998:  Adapt for Muon Collider                                 [EB]
    Oct. 2000   Adapt for use by NUMI. Remove expt specific stuff so that
                code can be used for any project with inclusion of 
                appropriate header file.                                [EB}
*****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pwd.h>
#include "notes.h"


#define INDEXDB "maxindex"
#define GET_INDEX "select maxindex from maxindex where tablename='%s'"
#define INCR_INDEX "update maxindex set maxindex='%d' where tablename='%s'"

#define INS_NEW "insert into %s values (%d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '','%s', null, null, null)"


main(int argc, char *argv[]) {
    /* From routine post-query.c */
    entry entries[MAX_ENTRIES];
    register int x,m=0;
    int cl;

    /* Declarations added by GC */
    MYSQL *db_sock;
    int i, ierr, j, indx;
    int off, length;
    int num_entries, num_recs;
    int c;

    time_t t;
    size_t strsize=50;
    const struct tm *timptr;
    char timstr[10];

    int prv_num, new_num;
    char date_req[11];
    char date_filed[11];
    char group_name[NUM_GROUPS][10];
    char category[10*NUM_GROUPS+(NUM_GROUPS-1)];
    int num_groups = 0;
    char class[11];
    char distribution[11];
    char file_name[101];
    char *user;
    char title[101];
    char authors[301];
    char pub_info[201];
    char requestor[51];

    char buf[2048];
    char ins_str[2 * MAX_LEN];
    /*    char outputs[NUM_INPUTS][MAX_LEN];*/

    MYSQL_RES *result;
    MYSQL_ROW cur;
    MYSQL_FIELD *curField;

    FILE *fp;


    /* Set up for html output */
    printf("Content-type: text/html%c%c",10,10);
    printf("<HEAD>\n");
    printf("<TITLE>New %s Note number assigned</TITLE>\n",PROJECT_NAME);
    printf("%s\n",STYLESHEET);
    printf("</HEAD>\n");
    printf("<BODY>\n");

    /* Make sure we're looking at POST method form results */
    if(strcmp(getenv("REQUEST_METHOD"),"POST")) {
        printf("This script should be referenced with a METHOD of POST.\n");
        printf("If you don't understand this, see this ");
	printf("<A HREF=\"%s\">forms overview</A>.\n", FORM_INFO_URL);
        exit(1);
    }
    if(strcmp(getenv("CONTENT_TYPE"),"application/x-www-form-urlencoded")) {
        printf("This script can only be used to decode form results. <BR>");
        exit(1);
    }
    cl = atoi(getenv("CONTENT_LENGTH"));

    /* Decode form results into individual fields and values */
    for(x=0;cl && (!feof(stdin));x++) {
        m=x;
        entries[x].val = fmakeword(stdin,'&',&cl);
        plustospace(entries[x].val);
        unescape_url(entries[x].val);
        entries[x].name = makeword(entries[x].val,'=');
    }
    num_entries = m + 1;

    /* Get today's date in format %m/%d/%y */
    t = time(NULL);
    timptr = localtime(&t);
    strftime(timstr, strsize, "%Y-%m-%d", timptr);
    printf("Today's date is %s<BR>", timstr);
    strcpy(date_req,timstr);


    /*-------------------------------------------------------*/
    /* mySQL-specific part */
    /*-------------------------------------------------------*/

    /* Construct bits of the query string from form inputs */
    for (i = 0; i < num_entries; i++) {
	if (!strcmp(entries[i].name, "title")) {
	    /* Check for special characters, and escape them */
	    mysql_escape_string(ins_str,entries[i].val,strlen(entries[i].val));
	    sprintf(title, "%s", ins_str);
	}
	else if (!strcmp(entries[i].name, "authors")) {
	    mysql_escape_string(ins_str,entries[i].val,strlen(entries[i].val));
	    sprintf(authors, "%s", ins_str);
	}
	else if (!strcmp(entries[i].name, "pub_info")) {
	    mysql_escape_string(ins_str,entries[i].val,strlen(entries[i].val));
	    sprintf(pub_info, "%s", ins_str);
	}
	else if (!strcmp(entries[i].name, "requestor")) {
	    mysql_escape_string(ins_str,entries[i].val,strlen(entries[i].val));
	    sprintf(requestor, "%s", ins_str);
	}
	else if (!strcmp(entries[i].name, "group")) {
	    sprintf(group_name[num_groups], "%s", entries[i].val);
	    num_groups++;
	}
	else if (!strcmp(entries[i].name, "class")) {
	    sprintf(class, "%s", entries[i].val);
	}
	else if (!strcmp(entries[i].name, "distribution")) {
	    sprintf(distribution, "%s", entries[i].val);
	}
	else if (!strcmp(entries[i].name, "file_name")) {
	    mysql_escape_string(ins_str,entries[i].val,strlen(entries[i].val));
	    sprintf(file_name, "%s", ins_str);
	}
	/* Request for Note, so no revision # or date_revised/filed */
    }

    /* Make sure authors and pub_info aren't too long */
    /*  (these use TEXTAREA fields, which don't have a MAXLENGTH attribute */
    if (strlen(authors) > MAX_LEN) {
	printf("Sorry, I can't take an Authors entry more than %d",MAX_LEN);
	printf("characters long.<BR>");
	printf("Please try again with a shorter list of Authors.");
	return;
    }
    if (strlen(pub_info) > MAX_LEN) {
	printf("Sorry, I can't take a Publication info entry more than %d",MAX_LEN);
	printf("characters long.<BR>");
	printf("Please try again with a shorter Pub info description.");
	return;
    }


    /* Now do mysql queries */

    db_sock = mysql_init(NULL);
    if (db_sock == NULL) {
	printf ("mysql_init() failed<BR>");
	return;
    }

    if(mysql_real_connect(db_sock,DBSERVER,USERNAME,PWORD,DB,0,NULL,0) == NULL) {
	printf ("error in connecting: %s<BR>",mysql_error(db_sock));
	return;
    }


    /**********  Table INDEXDB  **********/

    /* Get number of most recent Note, and assign next number to next_index */
    /* #define GET_INDEX "select maxindex from maxindex where tablename='%s'" */

    sprintf(buf, GET_INDEX, TABLE);
    if (mysql_query(db_sock, buf) == -1) {
	printf("Could not get maxindex: %s<P>",mysql_error(db_sock));
	printf("Query was: %s<P>", buf);
	exit(-1);
    }
    result = mysql_store_result(db_sock);
    if (!result) {
	printf("Error: query failed.<BR>");
	printf("Query was: %s<P>", buf);
	exit(-1);
    }
    cur = mysql_fetch_row(result);
    prv_num = atoi(cur[0]);
    new_num = prv_num + 1;

    /* Update the value in table maxindex */
    sprintf(buf, INCR_INDEX, new_num, TABLE);
    if (mysql_query(db_sock, buf) == -1) {
	printf("Could not update maxindex to %d:  %s<P>", new_num, mysql_error(db_sock));
	printf("Query was: %s<P>", buf);
	exit(-1);
    }

    /* Free storage */
    mysql_free_result(result);


    /**********  Table notes  **********/


    /* Make up the query string from new_num, dr_y, dr_m, 
	and the form inputs */
	/* #define INS_NEW "insert into %s values (
	    %d, '%s', '%s', '%s', '%s', 
	    '%s', '%s', '%s','%s', '', 
	    %s, null, null)" */

    /* Contruct string for group_name */

    for(i=0;i<num_groups;i++) {
      strcat(category,group_name[i]);
      if(i != num_groups-1) strcat(category,",");
    }
    
	sprintf(buf, INS_NEW, TABLE, 
		new_num, title, authors, pub_info, requestor, 
		category, class, distribution, file_name, 
		date_req);

    /* Issue the insert query */
    if (mysql_query(db_sock, buf) == -1) {
	printf("Could not assign new Note number %d: <BR>", new_num);
	printf("   %s <P>", mysql_error(db_sock));
	printf("Query was: %s<P>", buf);
	exit(-1);
    }
    else
	printf("Assigned new Note number <STRONG>%s-%s-%s-%d</STRONG> <P>", 
		NOTE_PREFIX,class, category, new_num);
    printf("Please type this string on the top right hand corner of your document<br>");
	printf("Query was: %s<P>", buf);


    /* Select the record to verify that it was inserted properly */
    /* #define SELECT_NUM "select * from %s where %s = %d" */
    sprintf( buf, SELECT_NUM, TABLE, SEL_FIELD, new_num);
    if (mysql_query(db_sock, buf) == -1) {
	printf("Could not find new Note number %d:  %s<P>", 
		new_num, mysql_error(db_sock));
	printf("Query was: %s<P>", buf);
	exit(-1);
    }
    result = mysql_store_result(db_sock);
    num_recs = mysql_num_rows(result);


    /* Format and print the results */
    printf("Here is the new record:<BR><BR>");
    notePrint(result);

    /* Send mail that this note number has been assigned */
    /* Record time of mail attempt in mail log file */
    sprintf(buf, "date >> %s 2>&1", MAILLOG);
    sprintf(buf, 
	"%s -s \"Note #%d assigned to %s\" %s < /dev/null >> %s 2>&1",
	MAIL, new_num, requestor, MAIL_TST, MAILLOG);
    /* Add mailing command to mail log file */
    fp = fopen(MAILLOG, "a");
    fprintf(fp, "%s\n", buf);
    fclose(fp);
    /* Send the mail */
    if ((ierr = do_cmd(buf)) != 0) exit(-1);
 
    /* Free memory used for query result, and disconnect socket */
    mysql_free_result(result);
    mysql_close(db_sock);


    return;
}


/********** local routines ********************/

int do_cmd(char *cmd) {
    FILE *fp;
    char retstr[256];
    retstr[0] = 0;
    fp = popen(cmd, "r");
    fgets(retstr, 200, fp);
    pclose(fp);
    if (strlen(retstr)) {
	printf("<H1>Error</H1><P>\n");
	printf("ERROR:  command %s failed\n", cmd);
	printf("Message:  %s\n", retstr);
	printf("</BODY>\n");
	exit(-1);
    }
    return(0);
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

