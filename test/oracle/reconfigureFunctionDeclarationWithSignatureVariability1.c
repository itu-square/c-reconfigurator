

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:1:1
int foo (long l , char c)
{
    return 0;
}

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:9:1
typedef int ttype;

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:11:0
ttype foo2 (long l , char c)
{
    return 0;
}

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:20:1
// defined(ENABLE_A)
typedef int inttype_V1;

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:22:1
// !defined(ENABLE_A)
typedef long inttype_V2;

// source/reconfigureFunctionDeclarationWithSignatureVariability1.c:25:0
inttype foo3 (long l , char c)
{
    return 0;
}