#include <stdlib.h>

// Define a structure for stack elements (representing call frames)
typedef struct {
    int n;
    int return_value; // To store intermediate results
} StackFrame;

// Basic Stack implementation (for demonstration)
#define MAX_STACK_SIZE 100
StackFrame stack[MAX_STACK_SIZE];
int top = -1;

void push(StackFrame frame) {
    if (top < MAX_STACK_SIZE - 1) {
        stack[++top] = frame;
    } else {
        exit(EXIT_FAILURE);
    }
}

StackFrame pop() {
    if (top >= 0) {
        return stack[top--];
    } else {
        exit(EXIT_FAILURE);
    }
}

int is_empty() {
    return top == -1;
}

int factorial_iterative(int n) {
    int result = 1;
    StackFrame current_frame;

    // Initial call: push the starting value
    push((StackFrame){.n = n, .return_value = 0});

    while (!is_empty()) {
        current_frame = pop();

        // result not ready
        if (current_frame.n == 0) {
            // Base case: return 1
            result = 1; 
            // If there's a caller waiting, update its return_value
            if (!is_empty()) {
                stack[top].return_value = result;
            }
        } else {
            // Simulate recursive call: push current state, then push next state
            push((StackFrame){.n = current_frame.n, .return_value = 0}); // Push current state to resume later
            push((StackFrame){.n = current_frame.n - 1, .return_value = 0}); // Push next call's state
        }

        // If a return value is present, it means a sub-problem just finished
        if (current_frame.return_value != 0) {
            // Multiply with the current 'n' and store in the caller's frame
            if (!is_empty()) {
                stack[top].return_value = current_frame.n * current_frame.return_value;
            } else { // If stack is empty, this is the final result
                result = current_frame.n * current_frame.return_value;
            }
        }
    }
    return result;
}
