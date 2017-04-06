

// source/prepare/IsolateDeclarationRule.c:2:1
// defined(ENABLE_A)
int i_V1;

// source/prepare/IsolateDeclarationRule.c:4:1
// defined(ENABLE_A)
typedef int t_V1;

// source/prepare/IsolateDeclarationRule.c:6:1
// defined(ENABLE_A)
struct s_V1
{
}
;

// source/prepare/IsolateDeclarationRule.c:11:1
// defined(ENABLE_A)
union u_V1
{
}
;

// source/prepare/IsolateDeclarationRule.c:16:1
// defined(ENABLE_A)
enum e
{
    FIRST_V1}
;

// source/prepare/IsolateDeclarationRule.c:21:1
// defined(ENABLE_A)
void foo_V1 ()
{
// source/prepare/IsolateDeclarationRule.c:24:2
// defined(ENABLE_B)
    int i_V2;
// source/prepare/IsolateDeclarationRule.c:26:2
// defined(ENABLE_B)
    long l_V1;
// source/prepare/IsolateDeclarationRule.c:28:1
// defined(ENABLE_A) && defined(ENABLE_B)
    t_V1 tvar_V1;
// source/prepare/IsolateDeclarationRule.c:28:1
// !defined(ENABLE_A) && defined(ENABLE_B)
    t tvar_V2;
}