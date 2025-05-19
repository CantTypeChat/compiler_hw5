
typedef struct _Node {
    int value;
    struct _Node* next;
} Node;

void Init();
void Solve();


int main()
{
    Init();
    Solve();
    return 0;
}

typedef Node* Stack;

Stack s;

void Init()
{
    s = (Stack) malloc(sizeof(Node*));
}

void Solve()
{
    return;
}
