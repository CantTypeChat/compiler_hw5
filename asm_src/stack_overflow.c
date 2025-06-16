int big_recursive();

int main() {
    big_recursive();
    return 0;
}

int big_recursive() {
    int array[1024];
    return big_recursive();
}


