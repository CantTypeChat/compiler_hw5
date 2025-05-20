

int main()
{

    int i = 10;
    for(i = 0; i < 100; i++) {
        printf("hello, world!\n");
    }
    do {
        printf("hello, world!\n");
    } while(i--);

    while(i++ < 10) {
        printf("hello, world!\n");
    }

    return 0;
}
