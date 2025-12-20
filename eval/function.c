int function(int n) {
  if(n <= 1) { return 1; }
  int a = function(n-1);
  return a * a + n;
}

int function_recurse_rep(int n) {
  unsigned sp = 0;

  int stack_arg[512];
  int stack_state[512];
  int stack_ret[512];

  stack_arg[sp]   = n;
  stack_state[sp] = 0;

loop_start:
  if (stack_state[sp] == 0) {

    if (stack_arg[sp] <= 1) {
      stack_ret[sp] = 1;
      if (sp == 0) {
        return stack_ret[0];
      }
      sp--;
      goto loop_start;
    }
    stack_state[sp] = 1;
    sp++;
    stack_state[sp] = 0;
    stack_arg[sp]   = stack_arg[sp-1] - 1;
    goto loop_start;
  }
  if (stack_state[sp] == 1) {
    stack_ret[sp] = stack_ret[sp+1] * stack_ret[sp+1] + stack_arg[sp];
    if (sp == 0) {
      return stack_ret[0];
    }
    sp--;
    goto loop_start;
  }
}

/*
typedef struct {
  int n;
  int ret;
  int local_var;
  int state;
} Frame;

int function_iter(int n) {
  int top = -1;
  Frame stack[512];

  Frame start = {n, 0, 0, 0};
  stack[++top] = start; 
  
  int result = 0;
  while(top != -1) {
    Frame f = stack[top--]; 
    if (f.state == 0) {    // Before Recursive Call
      if(f.n <= 1) {       // Base Case
        f.ret = f.n;
        result = f.ret;
        if (top != -1) { stack[top].local_var = f.ret; }
      } else {             // Recursive Call
        f.state = 1;
        stack[++top] = f;      
        Frame child = {f.n -1, 0, 0, 0};
        stack[++top] = child;      
      }
    } else {               // After Recursive Call
      f.ret = f.local_var * f.local_var + f.n;
      result = f.ret;
      if (top != -1) { stack[top].local_var = f.ret; }
    }
  }
  return result;
}*/

// Fully optimized version (too extreme)
/*
int function_iter(int n) {
  int result;
  if(n <= 1) { return n; }
  result = 1;
  for(int i = 2; i <= n; i++) {
    result = result * result + i;
  }
  return result;
}
*/

int function_iter(int n) {
  int stack[512];
  int top = -1;
  while(n > 1) {
    stack[++top] = n;
    n = n-1;
  }
  int result = n;

  while(top != -1) {
    int v = stack[top--];
    result = result * result + v;
  }
  return result;
}

/*
int main() {
  #include <stdio.h>
  printf("Recursive function: %d\n", function(15));
  printf("Iterative function: %d\n", function_iter(15));
  printf("Recursive function translated to Iterative function: %d\n", function_recurse_rep(15));
  return 0;
}
*/
