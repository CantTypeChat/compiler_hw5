typedef struct _Node {
    int data;
    struct _Node* next;
} Node;

typedef struct _Queue {
    Node *front, *back;
    int size;
} Queue;

void init(Queue* q);
void push(Queue* q, int data);
int  pop(Queue* q);
int is_empty(Queue* q);
int size(Queue* q);
void free(void* );
int main()
{
    int n, i;
    Queue q;
    init(&q);
    scanf("%d", &n);
    for(i = 1; i <= n; i++)
        push(&q, i);
    while(1) {
        printf("%d ", pop(&q));
        if(is_empty(&q)) break;
        push(&q, pop(&q));
    }
    printf("\n");
    return 0;
}

void init(Queue* q)
{
    q->front = q->back = 0;
    q->size = 0;
}

void push(Queue* q, int data)
{
    Node* new_node = (Node*) malloc(sizeof(Node));
    new_node->data = data;
    new_node->next = 0;
    if(is_empty(q)) {
        q->front = q->back = new_node;
    } else {
        q->back->next = new_node;
        q->back = new_node;
    }
    q->size++;
}

int pop(Queue* q)
{
    Node* rm_node;
    int rm_data;
    if(is_empty(q)) return -1;
    rm_node = q->front;
    rm_data = rm_node->data;
    q->front = q->front->next;
    if(q->front == 0)
        q->back = 0;
    free(rm_node);
    q->size--;
    return rm_data;
}
int is_empty(Queue* q)
{
    return size(q) == 0;
}
int size(Queue* q)
{
    return q->size;
}

