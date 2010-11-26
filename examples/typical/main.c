#include <stdio.h>
#include <unistd.h>

#include <config.h>

int main(void)
{
#ifdef ENABLE_UTF8
	printf("UTF-8 is enabled\n");
#endif
#ifdef HAVE_SLEEP
	sleep(1);
#endif
	return 0;
}
