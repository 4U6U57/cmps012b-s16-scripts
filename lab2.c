#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>

#define scriptname "lab2"
#define testinput "/afs/cats.ucsc.edu/class/cmps012b-pt.s16/bin/lab2/test/testin"
#define testoutput "/afs/cats.ucsc.edu/class/cmps012b-pt.s16/bin/lab2/test/testout"
#define progfile "FileReverse"
#define perffile ".d.performance.f"
#define desfile ".d.design.f"
#define notes ".notes.f"
#define perfmax 5
#define desmax 5

#define min(x, y) (x < y ? x : y)

#define streq(x, y) !strncmp(x, y, min(strlen(x), strlen(y)) + 1)

char *sfgets(char *x, int y, FILE *fp) {
	char *temp = fgets(x, y, fp);
	if (temp) x[strlen(x) - 1] = '\0';
	return temp;
}

int parseInt(char *str) {
	if (!str) {
		printf("NULL string in parseInt()");
		exit(1);
	}
	int ret = 0;
	for (int i = 0; i < strlen(str); i++) {
		if (str[i] < '0' || str[i] > '9') return -1;
		ret += (str[i] - '0') * pow(10, strlen(str) - i - 1);
	}
	return ret;
}

void testProg(char *str) {
	if (!str) {
		printf("Given null filename for testing\r\n");
		return;
	}
	char temps[1024] = {};
	sprintf(temps, "%s.java", str);
	FILE *fp = fopen(temps, "r");
	if (!fp) {
		printf("Given non-existing file for testing\r\n");
		return;
	}
	fclose(fp);
	sprintf(temps, "cat %s.java", str);
	system(temps);
	sprintf(temps, "cp %s .", testinput);
	system(temps);
	sprintf(temps, "cp %s .", testoutput);
	system(temps);
	sprintf(temps, "javac -Xlint %s.java", str);
	system(temps);
	sprintf(temps, "java %s testin out", str);
	system(temps);
	printf("\r\n=====\r\nin:\r\n");
	sprintf(temps, "cat testin");
	system(temps);
	printf("\r\n=====\r\nout:\r\n");
	sprintf(temps, "cat out");
	system(temps);
	printf("\r\n=====\r\ndiff:\r\n");
	sprintf(temps, "diff -b out testout");
	system(temps);
	sprintf(temps, "rm -f *.class out in testin testout");
	system(temps);
	printf("\r\n");
}

int main (int argc, char **argv) {
	//printf("This script is not yet ready\r\n");
	//if (1) return 0;

	char cwd[1024];
	if (!getcwd(cwd, sizeof(cwd))) {
		printf("Warning: couldn't get current working directory\r\n");
		sprintf(cwd, "<unknown>");
	}

	int gradep = 5; // p: performance, d: design
	int graded = 5;
	char notesp[1024] = {};
	char notesd[1024] = {};

	FILE *fp = fopen(perffile, "r");
	if (fp) {
		printf("%s has already been graded\r\n", cwd);
		//char cont[20];
		fclose(fp);
		exit(0);
	}
	char temp[1024] = {};
	sprintf(temp, "%s.java", progfile);
	fp = fopen(temp, "r");
	if (!fp) {
		printf("Warning: %s.java not found\r\nNow setting grade to ", progfile);
		printf("zero and adding appropriate notes\r\n");
		gradep = 0;
		graded = 0;
		strcpy(notesp, "Output test failed due to lack of code\r\n");
		strcpy(notesd, "Design grade receives a zero due to lack of code\r\n");
	} else {
		fclose(fp);
		testProg(progfile);
	}
	for (;;) {
		printf("[%s]$ ", scriptname);
		sfgets(temp, 1023, stdin);
		if (streq(temp, "-h")) {
			printf("-h: help\r\n-gp: grade performance\r\n-gd: grade design\r\n");
			printf("-np: comments performance\r\n-nd: comments design\r\n");
			printf("-p: print test results\r\n-pc: specify file for -p\r\n");
			printf("-s: skip\r\n-w: write grade & comments\r\n");
		} else if (streq(temp, "-gp")) {
			int itemp;
			printf("Please enter a (int) performance grade [0, 5] for %s\r\n", cwd);
			sfgets(temp, 1023, stdin);
			itemp = parseInt(temp);
			while(itemp > 5 || itemp < 0) {
				printf("Please enter a (int) performance grade [0, 5] for %s\r\n", cwd);
				sfgets(temp, 1023, stdin);
				itemp = parseInt(temp);
			}
			gradep = itemp;
			printf("The performance grade is now %d/%d\r\n", gradep, perfmax);
		} else if (streq(temp, "-gd")) {
			int itemp;
			printf("Please enter a (int) design grade [0, 5] for %s\r\n", cwd);
			sfgets(temp, 1023, stdin);
			itemp = parseInt(temp);
			while(itemp > 5 || itemp < 0) {
				printf("Please enter a (int) design grade [0, 5] for %s\r\n", cwd);
				sfgets(temp, 1023, stdin);
				itemp = parseInt(temp);
			}
			graded = itemp;
			printf("The design grade is now %d/%d\r\n", graded, desmax);
		} else if (streq(temp, "-np")) {
			printf("Please enter the performance comments followed by an EOF\r\n");
			notesp[0] = '\0';
			while(fgets(temp, 1023, stdin)) {
				strcat(notesp, temp);
			}
			printf("Finished adding performance comments to %s\r\n", cwd);
		} else if (streq(temp, "-nd")) {
			printf("Please enter the design comments followed by an EOF\r\n");
			notesp[0] = '\0';
			while(fgets(temp, 1023, stdin)) {
				strcat(notesp, temp);
			}
			printf("Finished adding design comments to %s\r\n", cwd);
		} else if (streq(temp, "-p")) {
			//sfgets(temp, 1023, stdin);
			testProg(progfile);
		} else if (streq(temp, "-pc")) {
			printf("Please enter a file to try to use for testing\r\n");
			sfgets(temp, 1023, stdin);
			testProg(temp);
		} else if (streq(temp, "-s")) {
			printf("Skipping %s\r\n", cwd);
			return 0;
		} else if (streq(temp, "-w")) {
			break;
		} else {
			system(temp);
		}
	}
	fp = fopen(perffile, "w");
	fprintf(fp, "%d / %d | %s\r\n", gradep, perfmax, gradep == 5 ? "Nice Job" : "Please see Performance Notes");
	fclose(fp);
	fp = fopen(desfile, "w");
	fprintf(fp, "%d / %d | %s\r\n", graded, desmax, graded == 5 ? "Nice Job" : "Please see Design Notes");
	fclose(fp);
	fp = fopen(notes, "a");
	fprintf(fp, "\r\n====================\r\n");
	fprintf(fp, "Performance Notes:\r\n\r\n");
	fprintf(fp, "%s", notesp);
	fprintf(fp, "\r\n====================\r\n");
	fprintf(fp, "Design Notes:\r\n\r\n");
	fprintf(fp, "%s", notesd);
	fprintf(fp, "\r\n====================\r\n");
	fclose(fp);
	printf("Successfully gave %s %d/%d for performance and %d/%d on design\r\n",
			cwd, gradep, perfmax, graded, desmax);
}
