

// source/normalize/SplitConditionalRule.c:2:1
// ENABLE_A && ENABLE_B
int ab_V1;

// source/normalize/SplitConditionalRule.c:8:1
// !ENABLE_A && !ENABLE_B
int none_V1;

// source/normalize/SplitConditionalRule.c:4:1
// ENABLE_A && !ENABLE_B
int a_V1;

// source/normalize/SplitConditionalRule.c:6:1
// !ENABLE_A && ENABLE_B
int b_V1;