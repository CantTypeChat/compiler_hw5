int main() {
    int *p;
    int i;
    p = (int*) malloc(sizeof(int) * 10);
    printf("== POINTER[INTEGER] approach test ==\n");
    for(i = 0; ; i++) {
        p[i] = i;
        printf("[%d]: %d\n", i, p[i]);
    }
    return 0;
}
