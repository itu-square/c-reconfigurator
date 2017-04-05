int a[
#ifdef ENABLE_A
	3
#else
	10
#endif
	];

int b[
#ifdef ENABLE_A
	3
#else
	10
#endif
	] = {0, 0, 0};

void foo()
{
	int a[
	#ifdef ENABLE_A
		3
	#else
		10
	#endif
		];

	int b[
	#ifdef ENABLE_A
		3
	#else
		10
	#endif
		] = {0, 0, 0};	
}