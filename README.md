# Верификация ПО

## Лабораторная №1
    cd lab1; spin -a main.pml; gcc -o pan pan.c; ./pan -D | dot -T ps | ps2pdf - main.pdf

## Лабораторная №2
### Без мьютекса
    cd lab2; spin -v main.pml; spin -a -o3 main.pml; gcc -o pan pan.c; ./pan -D | dot -T ps | ps2pdf - main.pdf
### С мьютексом
    cd lab2; spin -v main_mutex.pml; spin -a -o3 main_mutex.pml; gcc -o pan pan.c; ./pan -D | dot -T ps | ps2pdf - main_mutex.pdf
