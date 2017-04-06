int _reconfig_ENABLE_A;


// source/normalize/MergeConditionalsRule.c:1:2
int foo ()
{
// source/normalize/MergeConditionalsRule.c:3:3
    int x;
    if ((_reconfig_ENABLE_A))
    {
        x ++;
        x --;
    }
    return x;
}