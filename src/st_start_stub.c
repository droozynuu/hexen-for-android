#include <stdio.h>
#include <stdarg.h>
#include "st_start.h"
#include <android/log.h>
void ST_Init(void) {
}
void ST_Done(void) {
}

extern void ST_Message(char *message, ...) {
	char buf[100];
 va_list v;
 va_start(v,message);
 //vprintf(message,v);
 sprintf(buf, message, v);
 va_end(v);
 
 __android_log_print(ANDROID_LOG_INFO, "hexen", buf);
}

extern void ST_RealMessage(char *message, ...) {
	   char buf[100];
	va_list v;
	va_start(v,message);
	//vprintf(message,v);
	sprintf(buf, message, v);
	va_end(v);
	
	__android_log_print(ANDROID_LOG_INFO, "hexen", buf);
}

extern void ST_Progress(void) {
}

extern void ST_NetProgress(void) {
}

extern void ST_NetDone(void) {
}
