int weird(int n) {
  if(n <= 1) { return n; }
  int a = weird(n-1);
  return a * a + n;
}

typedef struct {
  int n;
  int ret;
  int local_var;
  int state;
} Frame;

#define MAXSTACK 100
Frame stack[MAXSTACK];

int top = -1;
extern inline void push(Frame f) { stack[++top] = f; }
extern inline Frame pop() { return stack[top--]; }

int weird_iter(int n) {
  Frame start = {n, 0, 0, 0};
  push(start);
  int result = 0;
  while(top != -1) {
    Frame f = pop();
    if (f.state == 0) {    // Before Recursive Call
      if(f.n <= 1) {       // Base Case
        f.ret = f.n;
        result = f.ret;
        if (top != -1) { stack[top].local_var = f.ret; }
      } else {             // Recursive Call
        f.state = 1;
        push(f);      // push current frame back on stack
        Frame child = {f.n -1, 0, 0, 0};
        push(child);  // push recursive frame onto stack
      }
    } else {               // After Recursive Call
      f.ret = f.local_var * f.local_var + f.n;
      result = f.ret;
      if (top != -1) { stack[top].local_var = f.ret; }
    }
  }
  return result;
}

int main() {
  //#include <stdio.h>
  //printf("Recursive Weird: %d\n", weird(3));
  //printf("Iterative Weird: %d\n", weird_iter(3));
  return 0;
}
