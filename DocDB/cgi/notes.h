/****************************************************************************
    notes.h

    Header file for the CDF Notes package

    Nov. 1996:  Reorganize code to increase modularity
						[Glenn Cooper, CDF/Fermilab]
 ****************************************************************************/

#ifndef __NOTES_H__
#define __NOTES_H__

#ifndef __MYSQL_H__
#define __MYSQL_H__
#include <mysql.h>
#endif

#include <stdio.h>

/*
 * DB, table info
 */
#define DB "btev_documents"
#define TABLE "notes"
#define NUM_GROUPS 64
#define NUM_FIELDS 14
#define NUM_CATS 8
#define NUM_CLASS 5

/*
 * Directories, URLs, machine names
 */
#define PUB "/www/html/btevdocs" /* loc. of docs */
#define PUB_URL "http://www-btev.fnal.gov/btevdocs" /* URL to files */
#define NOTES_URL  "http://www-btev.fnal.gov/internal_documents/docdb"
#define NOTES_PAGE "notes.html"			/* links to search/post/etc. */
#define DBSERVER "fnsimu1"			/* node where the db runs */
#define FORM_INFO_URL "http://www.ncsa.uiuc.edu/SDG/Software/Mosaic/Docs/fill-out-forms/overview.html"				/* NCSA info on HTML forms */
#define USERNAME "wsrvbtev"                     /* username to connect to DB */
#define PWORD "numiweb"                         /* password for DB */ 

/*
 * Project name,etc
 */
#define PROJECT_NAME "BTeV"                   /* Name of project */
#define NOTE_PREFIX "BTeVdoc"                    /* Prefix for notes */
#define FILE_PREFIX "btev"                    /* Prefix for file names */

/*
 * Mail info
 */
#define MAIL "/usr/bin/Mail"			/* mail program */
#define MAIL_LIST "garren@fnal.gov"	/* list to notify on posting */
#define MAIL_TST  "garren@fnal.gov"		/* list for testing */
#define PROB_ADDRESS  "garren@fnal.gov"        /*to report problems */
#define REPLY_ADDRESS "garren@fnal.gov"	/* for problems, comments */
#define REPLY_PERSON  "Lynn Garren"		/* for problems, comments */
#define MAILLOG "/var/tmp/btevnoteMail.log"		/* log file */

/*
 * Constants
 */
#define MAX_DOCS 100		/* (default) max # notes returned from search */
#define MAX_ENTRIES 10000	/* max # of entries from form */
#define MAX_LEN 255		/* max # chars in 1 field in notes table */
#define MAX_WORDS 100		/* max # of words in 1 form entry */

/*
 * Macros for constructing query strings
 */
#define LIMIT "%s limit %d"
#define ORDER  "%s order by %s desc"
#define SELECT "select * from %s where "
#define SELECT_NUM "select * from %s where %s = %d"
#define ORDER_FIELD "number"
#define SEL_FIELD "number"
#define UPDATE_CHAR "update %s set %s='%s' where %s = %d"
#define UPDATE_NUM  "update %s set %s=%d where %s = %d"

/* Strings for constructing html pages on the fly */

static char opt_str[NUM_CATS][100]={"<OPTION VALUE=\"STEEL\">Physics - Charm", 
  "<OPTION VALUE=\"SCINT\"> Physics - Beauty",
  "<OPTION VALUE=\"SIM\"> Physics - Other",
  "<OPTION VALUE=\"COMP\"> Detector",
  "<OPTION VALUE=\"ELEC\"> Computing",
  "<OPTION VALUE=\"ANA\"> Software",
  "<OPTION VALUE=\"GEN\"> General",
  "<OPTION VALUE=\"BEAM\"> Meeting"};

static char opt_str_sel[NUM_CATS][100]={"<OPTION VALUE=\"STEEL\" SELECTED>Physics - Charm", 
  "<OPTION VALUE=\"SCINT\" SELECTED> Physics - Beauty",
  "<OPTION VALUE=\"SIM\" SELECTED> Physics - Other",
  "<OPTION VALUE=\"COMP\" SELECTED> Detector",
  "<OPTION VALUE=\"ELEC\" SELECTED> Computing",
  "<OPTION VALUE=\"ANA\" SELECTED> Software",
  "<OPTION VALUE=\"GEN\" SELECTED> General",
  "<OPTION VALUE=\"BEAM\" SELECTED> Meeting"};

static char opt_name[NUM_CATS][20]={"STEEL","SCINT","SIM","ELEC",
  "THESEUS","ONLINE","COMP","GEN","BEAM","ANA"};

static char class_name[NUM_CLASS][20]={"NOTE","CONF","PUB","TRANS","MIN"};

static char class_str_check[NUM_CLASS][100]={ 
"<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"NOTE\" CHECKED> NOTE",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"CONF\" CHECKED> CONF",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"PUB\" CHECKED> PUB",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"TRANS\" CHECKED> TRANS",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"MIN\" CHECKED> MIN"};

static char class_str[NUM_CLASS][100]= {
"<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"NOTE\"> NOTE",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"CONF\"> CONF",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"PUB\"> PUB",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"TRANS\"> TRANS",
  "<INPUT TYPE=\"radio\" NAME=\"class\" VALUE=\"MIN\"> MIN"};

#define STYLESHEET "<SCRIPT LANGUAGE=\"javascript\" TYPE=\"text/javascript\">
<!-- serve an alternate style sheet for XWindows users
if (navigator.appVersion.indexOf(\"X11\") != -1) {
        document.write (\'<LINK rel=\"stylesheet\" type=\"text/css\" href=\"/styles/style_x11.css\">\')
} else  {
        document.write (\'<LINK rel=\"stylesheet\" type=\"text/css\" href=\"/styles/style.css\">\')
}
//-->
</SCRIPT>"

/*
 * Def's for parsing HTML forms, from NCSA
 */
typedef struct {
    char *name;
    char *val;
} entry;
char *makeword(char *line, char stop);
char *fmakeword(FILE *f, char stop, int *len);
char x2c(char *what);
void unescape_url(char *url);
void plustospace(char *str);

#endif /* __NOTES_H__ */




