int _reconfig_ENABLE_B;
int _reconfig_ENABLE_A;


// source/normalize/OptimizeAssignmentExpressionRule.c:1:1
void foo ()
{
// source/normalize/OptimizeAssignmentExpressionRule.c:3:2
    int x;
// source/normalize/OptimizeAssignmentExpressionRule.c:3:2
    int y;
    if ((_reconfig_ENABLE_A))
         x = 1;
    else
         x = 2;
    (
     (_reconfig_ENABLE_B)
     ? x = 3
     : y = 3);
}