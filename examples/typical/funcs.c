#include <unistd.h>
#include <config.h>

int func1(int p[2])
{
#ifdef HAVE_PIPE
	return pipe(p);
#endif
	return -1;
}
