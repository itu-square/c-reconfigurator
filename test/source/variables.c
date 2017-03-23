#define SOME_VALUE 88
#define SOME_OTHER_VALUE 42

int a;

#ifndef x
int x;
#endif

#ifdef ENABLE_B
int b;
#endif

#ifdef ENABLE_C
int c = 5;
#else
int c = 10;
#endif

#ifdef ENABLE_MAIN
int main(int argc, char const *argv[])
{
	#ifdef ENABLE_D
	int d = 50;
	#else
	int d = 100;
	#endif

	x = d;
	
	d = x;

	#ifdef ENABLE_PROCESS
	# ifdef ENABLE_D
	d = 500;
	b = SOME_VALUE;
	# else
	d = 1000;
	b = SOME_OTHER_VALUE;
	# endif
	#endif

	return 0;
}
#endif
