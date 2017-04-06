void foo(int x) 
{
	if (x == 0)
	#ifdef ENABLE_A
	{
		x++;
		x--;
	}
	#elif ENABLE_B
	{
		x = x + 1;
	}
	else
		x = x + 2;
	#else
		x = x + 3;
	#endif

} 
