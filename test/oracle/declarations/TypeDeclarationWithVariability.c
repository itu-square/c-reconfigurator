

// source/declarations/TypeDeclarationWithVariability.c:2:1
// defined(ENABLE_A)
typedef int t_V1;

// source/declarations/TypeDeclarationWithVariability.c:4:1
// !defined(ENABLE_A)
typedef long t_V2;

// source/declarations/TypeDeclarationWithVariability.c:7:0
// defined(ENABLE_A)
t_V1 x_V1;

// source/declarations/TypeDeclarationWithVariability.c:7:0
// !defined(ENABLE_A)
t_V2 x_V2;