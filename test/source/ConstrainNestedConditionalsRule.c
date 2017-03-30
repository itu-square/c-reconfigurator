#if defined(ENABLE_A) && defined(ENABLE_B)
int foo() {

	int x;

	#if defined(ENABLE_A) && defined(ENABLE_C)
	x = callA();
	#endif

	#if defined(ENABLE_B) || defined(ENABLE_C)
	x = callB();
	#endif

	return x;

}
#endif
