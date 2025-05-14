int fib(int a) {
    if(a <= 1)
        return a;
    else
        return fib(a-1) + fib(a-2);
}

int main()
{
    printf("%d", fib(10));
    return 0;
}
