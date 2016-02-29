#if 1
int main ()
{
    #if !(defined A)
    #if (defined A)
    #if (defined A) && (defined B)
    return 0;
    #elif (defined A) && !(defined B)
    return - 1;
    #endif
    #endif
    #elif (defined A)
    #if (defined A)
    #if (defined A) && (defined B)
    return 0;
    #elif (defined A) && !(defined B)
    return - 1;
    #endif
    #endif
    #endif
}
#endif
#if (defined Y)
#if (defined Y) && (defined X)
int main ()
{
    #if (defined Y) && (defined X)
    return 0;
    #endif
}
#elif (defined Y) && !(defined X)
int main ()
{
    #if (defined Y) && !(defined X)
    return - 1;
    #endif
}
#endif
#endif
