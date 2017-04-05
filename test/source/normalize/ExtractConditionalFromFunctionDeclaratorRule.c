#ifdef ENABLE_A
int
#else
long
#endif
     foo (
#ifdef ENABLE_B
     		int x,
#endif
#ifdef ENABLE_A
     				char c,
#else
     				char cc,
#endif
     						 long g);
