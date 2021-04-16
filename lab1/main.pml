proctype Sum(int res; byte lhs; byte rhs)
{
    res = lhs + rhs;
}

init
{
    int res;
    byte lhs = 5;
    byte rhs = 3;
    run Sum(res, lhs, rhs);
    printf("%d + %d = %d\n", lhs, rhs, res);
}
