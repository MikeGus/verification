# Верификация ПО

## Лабораторная №1
    cd lab1; spin -a main.pml; gcc -o pan pan.c; ./pan -D | dot -T ps | ps2pdf - main.pdf
