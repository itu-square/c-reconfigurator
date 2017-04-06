#ifdef ENABLE_A
int i;

typedef int t;

struct s
{
	
};

union u
{

};

enum e
{
	FIRST
};

void foo()
{
	#ifdef ENABLE_B
	int i;

	long l;

	t tvar;
	#endif
}
#endif
