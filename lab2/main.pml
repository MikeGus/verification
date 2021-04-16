int val = 0;

proctype IncrementAndPrint()
{
    val = val + 1;
    printf("Value is %d\n", val);
}

proctype WorkerA()
{
    do
    ::  (val < 2) -> run IncrementAndPrint();
    ::  (val >= 2) -> break;
    od
}

proctype WorkerB()
{
    do
    ::  (val < 2) -> run IncrementAndPrint();
    ::  (val >= 2) -> break;
    od
}

init
{
    run WorkerA();
    run WorkerB();
}
