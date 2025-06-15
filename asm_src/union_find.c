int Find(int);
void Union(int, int);
void UnionInfo();
void PrintInfo();

int root[1024];
int depth[1024];
int n, r;
int target_1, target_2;

void PrintInfo() {
    printf("Union-Find algorithm example \n");
    printf("with path-compression, union-by-height\n\n");
    printf("there are humans and their friendship relationships.\n");
    printf("if there are 3 humans and 2 relationships, input would be : \n");
    printf("3 2\n1 3\n2 3\n");
    printf("which means 1 and 3 are friends, and 2 and 3 are also friends.\n");
    printf("I would like to know which humans belong to the same group.\n");
    printf("So, the following input would be :\n");
    printf("1 3\n\n");
    printf("input belows:\n");
}

int main()
{
    int i;
    
    PrintInfo();

    
    scanf("%d %d", &n, &r);
    for(i = 1; i <= n; i++) {
        root[i] = i;
        depth[i] = 0;
    }

    for(i = 0; i < r; i++) {
        int human_1, human_2;
        scanf("%d %d", &human_1, &human_2);
        Union(human_1, human_2);
    }

    printf("are these two people friends? : ");
    scanf("%d %d", &target_1, &target_2);
    if(Find(target_1) == Find(target_2)) {
        printf("They're friends!\n");
    } else {
        printf("They don't know each other.\n");
    }

    UnionInfo();
    return 0;
}

int Find(int idx) {
    if(root[idx] == idx)
        return idx;
    else
        return root[idx] = Find(root[idx]);
}

void Union(int h1, int h2)
{
    h1 = Find(h1);
    h2 = Find(h2);

    if(h1 == h2)
        return;

    if(depth[h1] < depth[h2]) {
        root[h1] = h2;
    } else if (depth[h1] == depth[h2]) {
        root[h1] = h2;
        depth[h2]++;
    } else {
        root[h2] = h1;
    }
}

void UnionInfo()
{
    int i;
    printf("== Union Find Info ==\n");
    for(i = 1; i <= n; i++)
        printf("[%d]: %d [d:%d]\n", i, root[i], depth[i]);
}
