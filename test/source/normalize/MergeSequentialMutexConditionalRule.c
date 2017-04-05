int foo()
{
	int x;

	#if defined(ENABLE_A) && defined(ENABLE_B)
	x = 1;
	x++;
	#endif

	#if defined(ENABLE_A) && !defined(ENABLE_B)
	x = 1;
	x++;
	#endif

	return x;
} 
