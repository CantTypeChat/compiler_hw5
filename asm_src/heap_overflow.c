int main() {
    int* p;
    int n;
    int i;
    scanf("%d", &n);
    p = (int*) malloc(sizeof(int) * n);
    while(++i)
        printf("[%d]: %d\n", i, p[i] = i);
    return 0;
}
