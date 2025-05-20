

typedef int Data;

struct _Node {
    Data val;
    struct _Node* next;
};

typedef struct _Node Node;

struct _Queue {
    Node *front, *back;
    int size;

    int (*isEmpty)(struct _Queue);
    void (*Enqueue)(struct _Queue, Node*);
    Data (*Dequeue)(struct _Queue);
};

typedef struct _Queue Queue;

Node* makeNode(Data d);
Queue InitQueue();
int MyQueueIsEmpty(Queue);
int test( int (*)(Queue));

Node* makeNode(Data d) {
    Node* new_node = (Node*) malloc(sizeof(Node));
    new_node -> val = d;
    new_node -> next = 0;
    return new_node;
}

Queue InitQueue() {
    Queue q;
    q.size = 0;
    q.front = q.back = 0;
    q.isEmpty = MyQueueIsEmpty;
}

int main()
{
    test(MyQueueIsEmpty);
    return 0;
}

int MyQueueIsEmpty(Queue q) {
    return q.size == 0;
}


int test( int (*what)(Queue)) {
    Queue q = InitQueue();
    what(q);
    return 1;
}
