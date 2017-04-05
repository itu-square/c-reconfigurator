int foo(long l, char c)
{
	return 0;
}




typedef int ttype;

ttype foo2(long l, char c)
{
	return 0;
}




#ifdef ENABLE_A
typedef int inttype;
#else
typedef long inttype;
#endif

inttype foo3(long l, char c)
{
	return 0;
}

