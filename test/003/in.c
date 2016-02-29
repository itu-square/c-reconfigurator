int main()
{
#ifdef A
#ifdef B
	return 0;
#else
	return -1;
#endif
#endif
}


#ifdef Y
#ifdef X
int main()
{
	return 0;
}
#else
int main()
{
	return -1;
}
#endif
#endif
