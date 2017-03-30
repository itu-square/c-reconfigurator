#if defined(ENABLE_A) && defined(ENABLE_B)
int foo() {

	int x;

	#if defined(ENABLE_A)
	x = callA();
	#endif

	#if defined(ENABLE_B)
	x = callB();
	#endif

	return x;
	
}
#endif
