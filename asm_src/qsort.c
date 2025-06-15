
int comp(int, int);
int  partition(int [], int, int, int (*)(int, int));
void quick_sort(int[], int, int, int (*)(int, int));
void swap(int*, int*);

int cmp_asc(int a, int b)
{
    return a > b;
}

int cmp_dsc(int a, int b)
{
    return a < b;
}


int main() {
    int *array;
    int n, i;

    printf("quick sort example\n\n");
    printf("input array len: ");
    scanf("%d", &n);
    printf("input %d array elems: ", n);
    array = (int*) malloc(sizeof(int) * n);
    for(i = 0; i < n; i++)
        scanf("%d", &array[i]);
    
    quick_sort(array, 0, n-1, cmp_asc);
    printf("after sort asc     : ");
    for(i = 0; i < n; i++)
        printf("%d ", array[i]);
    printf("\n");

    quick_sort(array, 0, n-1, cmp_dsc);
    printf("after sort dsc     : ");
    for(i = 0; i < n; i++)
        printf("%d ", array[i]);
    printf("\n");


    return 0;
}


void quick_sort(int array[], int left, int right, int (*comp)(int, int)) {
    if (left <= right) {
        int pivot;
        pivot = partition(array, left, right, comp);
        quick_sort(array, left, pivot - 1, comp);
        quick_sort(array, pivot + 1, right, comp);
    }
}

int partition(int array[], int left, int right, int (*comp)(int, int)) {
    int *pivot;
    int low, high, i;

    pivot = &array[left];
    low = left + 1;
    high = right;

    do {
        while (low < right && comp(*pivot, array[low]))
            low++;

        while (left < high && comp(array[high], *pivot))
            high--;

        if(low < high)
            swap(&array[low], &array[high]);
    } while (low < high);

    swap(pivot, &array[high]);
    return high;
}

void swap(int* a, int* b)
{
    int tmp;
    tmp = *a;
    *a = *b;
    *b = tmp;
}
