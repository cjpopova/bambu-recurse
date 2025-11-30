
#include <limits.h>
#include <stdlib.h>

#define MAX_THRESH 4

/* Stack node declarations used to store unfulfilled partition obligations. */
typedef struct
  {
    char *lo;
    char *hi;
  } stack_node;

/* this explicit stack is copied from panda's qsort.  */
#define STACK_SIZE	(CHAR_BIT * sizeof(size_t))
#define PUSH(low, high)	((void) ((top->lo = (low)), (top->hi = (high)), ++top))
#define	POP(low, high)	((void) (--top, (low = top->lo), (high = top->hi)))
#define	STACK_NOT_EMPTY	(stack < top)

// this is some code that uses the stack (poorly)
char* use_stack(void *const pbase, size_t total_elems, size_t size) {
    char *base_ptr = (char *) pbase;

    char *lo = base_ptr;
    char *hi = &lo[size * (total_elems - 1)];

    stack_node stack[STACK_SIZE];
    stack_node *top = stack;

    PUSH(lo, hi);
    if (lo < hi) {
        PUSH(lo + size, hi - size);
    }
    POP(lo, hi);

    return lo;
}