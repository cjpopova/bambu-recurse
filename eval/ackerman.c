int r_ackerman(int m, int n)
{
    if(m==0){
        return n+1;
    }else if(m>0 && n==0){
        return r_ackerman(m-1, 1);
    }else{
        n=r_ackerman(m,n-1);
        return r_ackerman(m-1,n);
    }
}

int r_ackerman_iter(int m, int n)
{
    unsigned sp = 0;

    int stack_m[1024];
    int stack_n[1024];
    int stack_state[1024];
    int stack_ret[1024];

    /* push initial frame */
    stack_m[sp] = m;
    stack_n[sp] = n;
    stack_state[sp] = 0;

loop_start:
    /* ENTRY STATE */
    if (stack_state[sp] == 0) {

        /* if (m == 0) return n + 1; */
        if (stack_m[sp] == 0) {
            stack_ret[sp] = stack_n[sp] + 1;
            if (sp == 0) {
                return stack_ret[0];
            }
            sp--;
            goto loop_start;
        }

        /* else if (m > 0 && n == 0) return r_ackerman(m-1, 1); */
        if (stack_m[sp] > 0 && stack_n[sp] == 0) {
            stack_state[sp] = 1;      /* resume directly to return */
            sp++;
            stack_m[sp] = stack_m[sp-1] - 1;
            stack_n[sp] = 1;
            stack_state[sp] = 0;
            goto loop_start;
        }

        /* else: n = r_ackerman(m, n-1); */
        stack_state[sp] = 2;          /* resume after first recursive call */
        sp++;
        stack_m[sp] = stack_m[sp-1];
        stack_n[sp] = stack_n[sp-1] - 1;
        stack_state[sp] = 0;
        goto loop_start;
    }

    /* RESUME: after r_ackerman(m-1, 1) */
    if (stack_state[sp] == 1) {
        stack_ret[sp] = stack_ret[sp+1];
        if (sp == 0) {
            return stack_ret[0];
        }
        sp--;
        goto loop_start;
    }

    /* RESUME: after n = r_ackerman(m, n-1) */
    if (stack_state[sp] == 2) {
        stack_n[sp] = stack_ret[sp+1];
        stack_state[sp] = 3;

        /* return r_ackerman(m-1, n); */
        sp++;
        stack_m[sp] = stack_m[sp-1] - 1;
        stack_n[sp] = stack_n[sp-1];
        stack_state[sp] = 0;
        goto loop_start;
    }

    /* RESUME: after r_ackerman(m-1, n) */
    if (stack_state[sp] == 3) {
        stack_ret[sp] = stack_ret[sp+1];
        if (sp == 0) {
            return stack_ret[0];
        }
        sp--;
        goto loop_start;
    }
}

/*
int main(){
  #include <stdio.h>
  printf("r_ackerman %d", r_ackerman(1,2));
  printf("r_ackerman_iter %d", r_ackerman_iter(1,2));
  return 0;
}
*/
