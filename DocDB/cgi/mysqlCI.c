/****************************************************************************
    mysqlCI.c

    Make a string case insensitive for mySQL queries:
    Return the result as outString.

    Liz Buckley-Geer October 2000
*****************************************************************************/

#include <string.h>

void mysqlCI(char *inString, char *outString) {

    int i, indx;

    /* Make search string case insensitive:  '[Aa][Bb]' etc. */
    indx = 0;
    for (i = 0;  i < strlen(inString);  i++) {
	if (isalpha(inString[i])) {
	    outString[indx++] = toupper(inString[i]);
	}
	else {
	    outString[indx++] = inString[i];
	}
    }

    /* Finally, terminate outString */
    outString[indx] = '\0';

    return;
}

