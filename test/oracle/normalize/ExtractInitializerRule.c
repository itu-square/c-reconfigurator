

// source/normalize/ExtractInitializerRule.c:1:1
char c [ 3 ] = "abc";

// source/normalize/ExtractInitializerRule.c:3:1
int data [ 5 ] =
{
    0 , 0 , 0 , 0 , 0}
;

// source/normalize/ExtractInitializerRule.c:5:1
long l = 12345;

// source/normalize/ExtractInitializerRule.c:7:1
void foo ()
{
// source/normalize/ExtractInitializerRule.c:9:2
    char c [ 3 ];
    c [ 0 ] = 'a';
    c [ 1 ] = 'b';
    c [ 2 ] = 'c';
// source/normalize/ExtractInitializerRule.c:11:2
    int data [ 5 ];
// source/normalize/ExtractInitializerRule.c:11:2
    int _reconfig_data_index;
    for (_reconfig_data_index = 0; _reconfig_data_index < 5; _reconfig_data_index ++)
    {
        data [ _reconfig_data_index ] = 0;
    }
// source/normalize/ExtractInitializerRule.c:13:2
    long l;
    l = 12345;
}