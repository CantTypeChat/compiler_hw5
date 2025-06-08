
void func();
int do_the_job();

void func() {
    do_the_job(1, 2);
}


int do_the_job() {
    return 1;
}


int main() {
    func();
    return 0;
}
