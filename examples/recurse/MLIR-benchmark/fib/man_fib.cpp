#include <stdint.h>

uint32_t man_fib(uint32_t n)
{
    const unsigned DEPTH=512;

    // BB2
    unsigned sp=0;
    uint32_t stack_n[DEPTH];
    uint32_t stack_r1[DEPTH];
    int stack_state[DEPTH];
    uint32_t retval;

    stack_n[sp]=n;
    stack_state[sp]=0;

    while(1){
        // BB4
        int state=stack_state[sp];
        uint32_t n=stack_n[sp];

        if(state==0){
            if(n<=2){ // BB5
                // BB6
                //  return 1;
                retval=1;
                if(sp==0){
                    break; // jump to BB15
                }else{
                    // BB 6B
                    sp--;
                }
            }else{
                // BB7
                // call fib(n-1);
                stack_state[sp]=1;
                sp++;
                stack_state[sp]=0;
                stack_n[sp]=n-1;
            }
        }else if(state==1){
            // BB8ish
            // completed r_fib(n-1)
            stack_r1[sp]=retval;
            // call fib(n-2);
            stack_state[sp]=2;
            sp++;
            stack_state[sp]=0;
            stack_n[sp]=n-2;

        }else if(state==2){
            // BB8ish
            // completed r_fib(n-2)
            retval=stack_r1[sp]+retval;
            // return
            if(sp==0){
                break;
            }else{
                // BB8b
                sp--;
            }
        }
        // BB3: phis
    }
    // BB15
    return retval;
}