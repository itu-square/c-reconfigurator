int _reconfig_ENABLE_A;


// source/normalize/EnforceBracesInSelectionStatementRule.c:1:1
void foo (int x)
{
    if ((!_reconfig_ENABLE_A && ENABLE_B))
    {
        if (x == 0)
        {
            x = x + 1;
        }
        else
         x = x + 2;
    }
    else
    {
        if (x == 0)
        {
            if ((_reconfig_ENABLE_A))
            {
                x ++;
                x --;
            }
            else
         x = x + 3;
        }
    }
}