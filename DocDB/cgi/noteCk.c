/****************************************************************************
    cdfnoteCk.c

    Perform a test query to the mcnotes database, to make sure that
	msqld is still running properly.
    If it isn't, send mail to relevant people.

    Apr. 1995:	Original routine		[Glenn Cooper, CDF/Fermilab]
*****************************************************************************/


#include <stdio.h>
#include <syslog.h>
#include <time.h>
#include <errno.h>
#include "notes.h"

#define SELF "noteCk"
#define TST_NUM 770
#define TST_QUERY "select * from %s where number=%d"
#define CKFILE "/var/tmp/noteCk.log"


void send_mail(char *mail_list, char *msg1, char *msg2) {
    char msg_buf[512];
    char tbuf[30];
    char cmd[256];
    int num_char;
    int i;
    time_t tloc;
    FILE *fp;

    for (i = 0; i < 30; i++)
	tbuf[i] = '-';
    time(&tloc);
    strcpy(tbuf, ctime(&tloc));

    sprintf(cmd, "/usr/ucb/Mail -s 'Possible mysqld problem' %s", mail_list);
    if ((fp = popen(cmd, "w")) != NULL) {
	sprintf(msg_buf, "A test query to the notes database failed at %s", 
		tbuf);
	strcat(msg_buf, "This may require killing and restarting mysqld.\n\n");
	sprintf(msg_buf, "%sSymptom:  %s\n", msg_buf, msg1);
	strcat(msg_buf, "mySQL error message:\n");
	sprintf(msg_buf, "%s    %s\n", msg_buf, msg2);
	if ((num_char = fprintf(fp, msg_buf)) < 0) {
	    syslog(LOG_ERR, "%s ERROR: fprintf failed; ret code is %d",
		SELF, num_char);
	}
	pclose(fp);
    }
    else {
	syslog(LOG_ERR, "%s ERROR: popen failed.", SELF);
    }
    fp = NULL;
}


void write_ok(void) {
    char tbuf[25];
    time_t tloc;
    FILE *fp;

    time(&tloc);
    strcpy(tbuf, ctime(&tloc));
    if ((fp = fopen(CKFILE, "a")) != NULL) {
	fprintf(fp, "notes DB access checked successfully at %s", tbuf);
	fclose(fp);
    }
    else {
	syslog(LOG_ERR, "%s ERROR: fopen for CKFILE failed, errno is %d ",
	    SELF, errno);
    }
    fp = NULL;
}


main(int argc, char *argv[]) {
    int numRecs;
    char buf[2048];
    MYSQL *db_sock;
    MYSQL_RES *result;

    /* Connect to mysqld */

    db_sock = mysql_init(NULL);
    if (db_sock == NULL) {
	send_mail(PROB_ADDRESS,"mysql_init() failed",mysql_error(db_sock));
	exit(-1);
    }

    if(mysql_real_connect(db_sock,DBSERVER,USERNAME,PWORD,DB,0,NULL,0) == NULL) {
	send_mail(PROB_ADDRESS,"error in connecting:",mysql_error(db_sock));
	exit(-1);
    }


    /* Compose the test mSQL query */
    sprintf(buf, TST_QUERY, TABLE, TST_NUM);

    /* Do the test query... */
    if (mysql_query(db_sock, buf) == -1) {
	send_mail(PROB_ADDRESS, "Query failed", mysql_error(db_sock));
	mysql_close(db_sock);
	exit(-1);
    }
    /* ... check that it returned properly... */
    result = mysql_store_result(db_sock);
    if (!result) {
	send_mail(PROB_ADDRESS, "test query failed", mysql_error(db_sock));
	mysql_close(db_sock);
	exit(-1);
    }
    /* ... and check that it returned a record */
    numRecs = mysql_num_rows(result);
    if (numRecs <= 0) {
	send_mail(PROB_ADDRESS, "0 rows returned", mysql_error(db_sock));
	mysql_close(db_sock);
	exit(-1);
    }

    /* If we got this far, everything looks OK, so add a line to CKFILE */
    write_ok();

    /* Free memory used for query result, and disconnect socket */
    mysql_free_result(result);
    mysql_close(db_sock);

    return;
}
