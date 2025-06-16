int main() {
    int i;
    int a[10];
    printf("== array out of bound test ==\n");
    for(i = 0; ; i++) {
        a[i] = i;
        printf("[%d]: %d\n", i, a[i]);
    }
    return 0;
}
