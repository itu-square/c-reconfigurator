 int foo()
 {
 	int x;

	#ifdef ENABLE_A
 	x++;
 	#endif

	#ifdef ENABLE_A
 	x--;
 	#endif

 	return x;
 }
