#if 1
int main ()
{
    #if (defined X) && !(defined Y)
    #if !(defined X) || (defined X) && (defined Y)
    #if (defined X) && (defined Y)
    return 0;
    #else
    return - 1;
    #endif
    #endif
    #else
    #if !(defined X) || (defined X) && (defined Y)
    #if (defined X) && (defined Y)
    return 0;
    #else
    return - 1;
    #endif
    #endif
    #endif
}
#endif
