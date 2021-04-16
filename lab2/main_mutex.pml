int val = 0;
int max_val = 10;

proctype Worker()
{
    do
    ::  atomic { (val >= max_val) -> break; }
    ::  atomic { (val < max_val) -> val++; printf("Value is %d\n", val); }
    od
}


init
{
    run Worker();
    run Worker();
}
