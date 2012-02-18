#include <SDL.h>
#include "h2def.h"


int UpdateState;
int isCyberPresent=0;
int DisplayTicker;

boolean devparm=false;


void I_ReadCyberCmd (ticcmd_t *cmd) {
// stub
}


int SDL_main(int argc, char *argv[])
{
	myargc = argc;
	myargv = argv;
	printf("Starting Hexen!\n");
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_NOPARACHUTE);
	atexit(SDL_Quit);
	H2_Main();
	return 0;
}
