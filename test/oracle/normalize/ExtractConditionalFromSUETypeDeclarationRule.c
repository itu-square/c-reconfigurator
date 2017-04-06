

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:1:1
// defined(ENABLE_A)
struct s_V1
{
    char c;
    int a;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:1:1
// !defined(ENABLE_A)
struct s_V2
{
    char c;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:10:1
// defined(ENABLE_B)
struct s1_V1
{
    char bb;
    int bbb;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:10:1
// !defined(ENABLE_B)
struct s1_V2
{
    char cc;
    int ccc;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:24:1
// defined(ENABLE_C)
union u_V1
{
    char c;
    int a;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:24:1
// !defined(ENABLE_C)
union u_V2
{
    char c;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:33:1
// defined(ENABLE_D)
struct u1_V1
{
    char bb;
    int bbb;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:33:1
// !defined(ENABLE_D)
struct u1_V2
{
    char cc;
    int ccc;
}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:47:1
// defined(ENABLE_D)
enum e
{
    FIRST_V1 ,
    SECOND_V1 ,
    THIRD_V1}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:47:1
// !defined(ENABLE_D)
enum e
{
    FIRST_V1 ,
    THIRD_V1}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:56:1
// defined(ENABLE_D)
enum e1
{
    FIRST_V1 ,
    SECOND_V1 ,
    THIRD_V1}
;

// source/normalize/ExtractConditionalFromSUETypeDeclarationRule.c:56:1
// !defined(ENABLE_D)
enum e1
{
    FOURTH_V1 ,
    FIFTH_V1}
;