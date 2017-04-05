

// source/typedef_struct_var1.c:3:1
// defined(ENABLE_A)
typedef int atype_V1;

// source/typedef_struct_var1.c:5:1
// !defined(ENABLE_A)
typedef long atype_V2;

// source/typedef_struct_var1.c:8:0
// defined(ENABLE_A)
atype_V1 avariable_V1;

// source/typedef_struct_var1.c:8:0
// !defined(ENABLE_A)
atype_V2 avariable_V2;

// source/typedef_struct_var1.c:10:1
int f (atype p)
{
    return p;
}

// source/typedef_struct_var1.c:15:1
// defined(ENABLE_X)
struct s_V1
{
    int f1;
    char f2;
    long x;
}
;

// source/typedef_struct_var1.c:15:1
// !defined(ENABLE_X)
struct s_V2
{
    int f1;
    char f2;
}
;

// source/typedef_struct_var1.c:24:1
// defined(ENABLE_X)
struct s_V1 svar_V1;

// source/typedef_struct_var1.c:24:1
// !defined(ENABLE_X)
struct s_V2 svar_V2;

// source/typedef_struct_var1.c:26:1
typedef struct s s_buf [ 1 ];