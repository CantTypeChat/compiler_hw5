int func(int, int);

int main() {
    func();
    func(1, 2.0);
    func(1, 2, 3);
    func(1, 2);
    return 0;
}

int func(int a, int b) {
    return a + b;
}
