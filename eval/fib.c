int fibonacci(int n) {
	if(n <= 2) { return 1; }
	return fibonacci(n-1) + fibonacci(n-2);
}

int fibonacci_iter(int n) {
    unsigned sp = 0;

    int stack_n[1024];
    int stack_state[1024];
    int stack_ret[1024];

    /* push initial frame */
    stack_n[sp] = n;
    stack_state[sp] = 0;

loop_start:
    /* ENTRY STATE */
    if (stack_state[sp] == 0) {

        /* base case */
        if (stack_n[sp] <= 2) {
            stack_ret[sp] = 1;
            if (sp == 0) {
                return stack_ret[0];
            }
            sp--;
            goto loop_start;
        }

        /* compute fibonacci(n-1) first */
        stack_state[sp] = 1;        /* resume after first call */
        sp++;
        stack_n[sp] = stack_n[sp-1] - 1;
        stack_state[sp] = 0;
        goto loop_start;
    }

    /* RESUME after fibonacci(n-1) */
    if (stack_state[sp] == 1) {
        stack_ret[sp] = stack_ret[sp+1]; /* save fib(n-1) */
        stack_state[sp] = 2;

        /* now compute fibonacci(n-2) */
        sp++;
        stack_n[sp] = stack_n[sp-1] - 2;
        stack_state[sp] = 0;
        goto loop_start;
    }

    /* RESUME after fibonacci(n-2) */
    if (stack_state[sp] == 2) {
        stack_ret[sp] =
            stack_ret[sp] + stack_ret[sp+1]; /* fib(n-1) + fib(n-2) */
        if (sp == 0) {
            return stack_ret[0];
        }
        sp--;
        goto loop_start;
    }
}

