int _reconfig_ENABLE_B;
int _reconfig_ENABLE_D;
int _reconfig_ENABLE_PROCESS;


// source/variables.c:6:1
int a;

// source/variables.c:9:1
int x;

// source/variables.c:13:1
// defined(ENABLE_B)
int b_V1;

// source/variables.c:17:1
// defined(ENABLE_C)
int c_V1 = 5;

// source/variables.c:19:1
// !defined(ENABLE_C)
int c_V2 = 10;

// source/variables.c:23:1
// defined(ENABLE_MAIN)
int main_V1 (int argc , char const* argv [ ])
{
// source/variables.c:26:2
// defined(ENABLE_D)
    int d_V1;
    if ((_reconfig_ENABLE_D))
         d_V1 = 50;
// source/variables.c:28:2
// !defined(ENABLE_D)
    int d_V2;
    if ((!_reconfig_ENABLE_D))
         d_V2 = 100;
    x = (
         (!_reconfig_ENABLE_D)
         ? d_V2
         : d_V1);
    (
     (!_reconfig_ENABLE_D)
     ? (d_V2 = x)
     : (d_V1 = x));
    if ((_reconfig_ENABLE_D && _reconfig_ENABLE_PROCESS))
    {
        d_V1 = 500;
        (
         (_reconfig_ENABLE_B)
         ? (b_V1 = 88)
         : (b = 88));
    }
    else
    {
        d_V2 = 1000;
        (
         (_reconfig_ENABLE_B)
         ? (b_V1 = 42)
         : (b = 42));
    }
    return 0;
}