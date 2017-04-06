

// source/normalize/SplitMultipleVariablesRule.c:1:1
int a;

// source/normalize/SplitMultipleVariablesRule.c:1:1
int b;

// source/normalize/SplitMultipleVariablesRule.c:1:1
int c;

// source/normalize/SplitMultipleVariablesRule.c:3:1
int d [ 2 ] =
{
    0 , 0}
;

// source/normalize/SplitMultipleVariablesRule.c:3:1
int e [ 8 ];

// source/normalize/SplitMultipleVariablesRule.c:5:1
int* s;

// source/normalize/SplitMultipleVariablesRule.c:5:1
int h;

// source/normalize/SplitMultipleVariablesRule.c:7:1
int* x;

// source/normalize/SplitMultipleVariablesRule.c:7:1
int* y;

// source/normalize/SplitMultipleVariablesRule.c:9:1
void foo ()
{
// source/normalize/SplitMultipleVariablesRule.c:11:2
    int a;
// source/normalize/SplitMultipleVariablesRule.c:11:2
    int b;
// source/normalize/SplitMultipleVariablesRule.c:11:2
    int c;
// source/normalize/SplitMultipleVariablesRule.c:13:2
    int d [ 2 ];
// source/normalize/SplitMultipleVariablesRule.c:13:2
    int _reconfig_d_index;
    for (_reconfig_d_index = 0; _reconfig_d_index < 2; _reconfig_d_index ++)
    {
        d [ _reconfig_d_index ] = 0;
    }
// source/normalize/SplitMultipleVariablesRule.c:13:2
    int e [ 8 ];
// source/normalize/SplitMultipleVariablesRule.c:15:2
    int* s;
// source/normalize/SplitMultipleVariablesRule.c:15:2
    int h;
// source/normalize/SplitMultipleVariablesRule.c:17:2
    int* x;
// source/normalize/SplitMultipleVariablesRule.c:17:2
    int* y;
}