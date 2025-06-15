int main() {
    char* p;
    int n;
    int i;
    scanf("%d", &n);
    if(n < 1) return 0;
    p = malloc(n);
    for(i = 0; i < n-1; i++)
        p[i] = (char) ('a' + i);
    p[n-1] = (char) 0;
    printf("%s\n", p);
    return 0;
}


