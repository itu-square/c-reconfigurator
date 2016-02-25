#if 1
int main ()
{
    #if !(defined Y)
    #if (defined Y)
    #if (defined Y) && (defined X)
    return 0;
    #elif (defined Y) && !(defined X)
    return - 1;
    #endif
    #endif
    #elif (defined Y)
    #if (defined Y)
    #if (defined Y) && (defined X)
    return 0;
    #elif (defined Y) && !(defined X)
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
