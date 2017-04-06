struct s
{
	char c;
	#ifdef ENABLE_A
	int a;
	#endif
};


struct s1
#ifdef ENABLE_B
{
	char bb;
	int bbb;
}
#else
{
	char cc;
	int ccc;
}
#endif
;

union u
{
	char c;
	#ifdef ENABLE_C
	int a;
	#endif
};


struct u1
#ifdef ENABLE_D
{
	char bb;
	int bbb;
}
#else
{
	char cc;
	int ccc;
}
#endif
;

enum e
{
	FIRST,
#ifdef ENABLE_D
	SECOND,
#endif
	THIRD
};

enum e1
#ifdef ENABLE_D
{
	FIRST,
	SECOND,
	THIRD
}
#else
{
	FOURTH,
	FIFTH
}
#endif
;
