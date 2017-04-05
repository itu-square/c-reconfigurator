

// source/normalize/ExtractConditionalFromFunctionDeclaratorRule.c:2:1
// defined(ENABLE_A) && !defined(ENABLE_B)
int foo_V1 (char c , long g);

// source/normalize/ExtractConditionalFromFunctionDeclaratorRule.c:2:1
// defined(ENABLE_A) && defined(ENABLE_B)
int foo_V2 (int x , char c , long g);

// source/normalize/ExtractConditionalFromFunctionDeclaratorRule.c:4:1
// !defined(ENABLE_A) && !defined(ENABLE_B)
long foo_V3 (char cc , long g);

// source/normalize/ExtractConditionalFromFunctionDeclaratorRule.c:4:1
// !defined(ENABLE_A) && defined(ENABLE_B)
long foo_V4 (int x , char cc , long g);