int test ( int *test) {
	int local_variable = *test;
	return local_variable;
}

int main(void) {
	int local_variable = 42;
	test(&local_variable);
	while (1);
	return 0;
}
