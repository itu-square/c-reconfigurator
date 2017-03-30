

// defined(ENABLE_A) && defined(ENABLE_B)
int foo_V1 ()
{
// source/ConstrainNestedConditionalsRule.c:4:2
    int x;
    x = callA ();
    x = callB ();
    return x;
}