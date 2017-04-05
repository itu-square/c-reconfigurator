int _reconfig_ENABLE_A;


// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:1:1
// defined(ENABLE_A)
int a_V1 [ 3 ];

// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:1:1
// !defined(ENABLE_A)
int a_V2 [ 10 ];

// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:9:1
// defined(ENABLE_A)
int b_V1 [ 3 ] =
{
    0 , 0 , 0}
;

// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:9:1
// !defined(ENABLE_A)
int b_V2 [ 10 ] =
{
    0 , 0 , 0}
;

// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:17:1
void foo ()
{
// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:19:2
// defined(ENABLE_A)
    int a_V3 [ 3 ];
// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:27:2
// defined(ENABLE_A)
    int b_V3 [ 3 ];
// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:19:2
// !defined(ENABLE_A)
    int a_V4 [ 10 ];
// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:27:2
// !defined(ENABLE_A)
    int b_V4 [ 10 ];
// source/normalize/ExtractConditionalFromArrayDeclaratorRule.c:27:2
    int _reconfig_b_index;
    for (_reconfig_b_index = 0; _reconfig_b_index < (
                                                     (_reconfig_ENABLE_A)
                                                     ? 3
                                                     : 10); _reconfig_b_index ++)
    {
        (
         (!_reconfig_ENABLE_A)
         ? (b_V2 [ _reconfig_b_index ] = 0)
         : (b_V1 [ _reconfig_b_index ] = 0));
    }
}