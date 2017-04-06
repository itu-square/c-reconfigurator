void foo()
{
	int x, y;

	x
	#ifdef ENABLE_A
	= 1;
	#else
	= 2;
	#endif

	#ifdef ENABLE_B
	x
	#else
	y
	#endif
	= 3;
} 
