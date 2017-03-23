 
#ifdef ENABLE_A
typedef int atype;
#else
typedef long atype;
#endif

atype avariable;

int f(atype p)
{
	return p;
}

struct s
  {
    int f1;
    char f2;
    #ifdef ENABLE_X
    long x;
    #endif
  };


typedef struct s s_buf[1];

