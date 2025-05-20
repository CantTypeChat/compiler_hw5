struct s {
    int a, b;
};
void main()
{
    void* b = (struct s*) malloc(sizeof(struct s*));
}

