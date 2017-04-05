int _reconfig_ENABLE_C;


// defined(ENABLE_A) && defined(ENABLE_B)
int foo_V1 ()
{
// source/normalize/ConstrainNestedConditionalsRule.c:4:2
    int x;
    if ((_reconfig_ENABLE_C))
         x = callA ();
    x = callB ();
    return x;
}