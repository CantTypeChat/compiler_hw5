int get_max(int [], int);
int get_min(int [], int);

void main() {
    int n;
    int a[10];
    int i;
    int max, min;

    scanf("%d", &n);
    for(i = 0; i < n; i++) {
        scanf("%d", &a[i]);
    }
    max = get_max(a, n);
    min = get_min(a, n);
    printf("max: %d, min: %d\n", max, min);
}

int get_max(int a[], int n)
{
    int max, i;
    max = a[0];
    for(i = 0; i < n; i++)
        if(a[i] > max)
            max = a[i];
    return max;
}

int get_min(int a[], int n)
{
    int min, i;
    min = a[0];
    for(i = 0; i < n; i++)
        if(a[i] < min)
            min = a[i];
    return min;
}
    
