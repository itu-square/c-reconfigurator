int _reconfig_ENABLE_A;


// source/normalize/MergeSequentialMutexConditionalRule.c:1:1
int foo ()
{
// source/normalize/MergeSequentialMutexConditionalRule.c:3:2
    int x;
    if ((_reconfig_ENABLE_A))
    {
        x = 1;
        x ++;
    }
    return x;
}