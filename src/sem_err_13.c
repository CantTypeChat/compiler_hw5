enum a {ZERO, ONE};

int main()
{
    int*ptr, i;
    enum a A;
    
    ptr = &i;
    A = ZERO;
    -ptr; "line 10";
    -0;
    -1.0;
    -'a';
    -A;

    return 0;
}


