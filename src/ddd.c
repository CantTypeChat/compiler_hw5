int func(int, ...);


int main()
{
    func(10);
    return 0;
}


int func(int a, ...) {
    return 100 + a;
}
