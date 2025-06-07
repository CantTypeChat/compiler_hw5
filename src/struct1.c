
struct _Node {
    int value;
    struct _Node* next;
};

typedef struct _Node Node;

int main() {
    Node a;
    int value;
    value = 10;
    a.value = value;
    return 0;
}
