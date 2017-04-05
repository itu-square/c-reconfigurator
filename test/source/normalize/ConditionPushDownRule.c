#if ENABLE_X
# if ENABLE_A && ENABLE_B
int ab;
# elif ENABLE_A
int a;
# elif ENABLE_B
int b;
# else
int none;
# endif
#endif
