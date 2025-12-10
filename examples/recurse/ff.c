int ff(int a, int b) {
    int local = a + b;
    if (a == 0) {
        return b;
    }
    int x = ff(a-1, local);
    int y = ff(a-1, x);
    return y + 1;
}

