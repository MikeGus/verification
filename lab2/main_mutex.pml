bit semaphore = true;
int val = 0;

inline wait(sem)
{
    atomic {
        sem -> sem = false
    }
}

inline signal(sem) {
    sem = true
}

proctype IncrementAndPrint()
{
    val = val + 1;
    printf("Value is %d\n", val);
}

proctype WorkerA()
{
    do
    ::  wait(semaphore);
    ::  (val < 2) -> run IncrementAndPrint();
    ::  (val >= 2) -> break;
    ::  signal(semaphore);
    od
}

proctype WorkerB()
{
    do
    ::  wait(semaphore);
    ::  (val < 2) -> run IncrementAndPrint();
    ::  (val >= 2) -> break;
    ::  signal(semaphore);
    od
}

init
{
    run WorkerA();
    run WorkerB();
}
