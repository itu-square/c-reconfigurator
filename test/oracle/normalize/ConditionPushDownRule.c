

// source/normalize/ConditionPushDownRule.c:9:1
// ENABLE_X && !ENABLE_A && !ENABLE_B
int none_V1;

// source/normalize/ConditionPushDownRule.c:3:1
// ENABLE_X && ENABLE_A && ENABLE_B
int ab_V1;

// source/normalize/ConditionPushDownRule.c:5:1
// ENABLE_X && ENABLE_A && !ENABLE_B
int a_V1;

// source/normalize/ConditionPushDownRule.c:7:1
// ENABLE_X && !ENABLE_A && ENABLE_B
int b_V1;