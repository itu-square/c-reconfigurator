#if 1
int main ()
{
    #if !(defined X)
    #if (defined X)
    return 0;
    #endif
    #elif (defined X)
    #if (defined X)
    return 0;
    #endif
    #endif
}
#endif
