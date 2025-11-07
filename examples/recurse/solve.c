#define N 4
int solve(int row, int col) {
    if (row == N || col == N)
        return 1;
    if ((row + col) % 3 == 0)
        return solve(row + 1, 0);
    return solve(row, col + 1) + solve(row + 1, col);
}

int main(void)
{
    return 0; // TODO: add test case
}

