int _reconfig_ENABLE_B;
int _reconfig_ENABLE_A;


// source/normalize/ExtractConditionalFromSwitchStatementRule.c:1:1
void foo (int x)
{
    if ((_reconfig_ENABLE_B))
    {
        switch (x)
        {
            case 0 : if ((_reconfig_ENABLE_A))
            {
                x ++;
                x --;
            }
            else
            {
                x ++;
            }
            break;
            case 1 : case 2 : if ((_reconfig_ENABLE_A))
            {
                x = x + 2;
                x = x + 3;
            }
            else
            {
                x = x + 2;
            }
            break;
            case 3 :
            {
                x = x - 10;
            }
            break;
            case 4 : x = x + 9;
        }
    }
    else
    {
        switch (x)
        {
            case 0 : if ((_reconfig_ENABLE_A))
            {
                x ++;
                x --;
            }
            else
            {
                x ++;
            }
            break;
            case 1 : case 2 : if ((_reconfig_ENABLE_A))
            {
                x = x + 2;
                x = x + 3;
            }
            else
            {
                x = x + 2;
            }
            break;
            case 3 : case 4 : x = x + 9;
        }
    }
}