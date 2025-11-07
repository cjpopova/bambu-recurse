int mc91(int n) {
    if (n > 100)
        return n - 10;
    else
        return mc91(mc91(n + 11));
}

int main(void)
{
    if (mc91(87) != 91) {
        return 1;
    }
    else {
    	return 0;
    }
}
