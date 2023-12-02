#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	int depth;
	int last;
	int increased = 0;
	int decreased = 0;

	input >> last;

	cout << last << " (N/A - no previous measurement)" << endl;
	while (input >> depth)
	{
		cout << depth << " ";
		if (depth > last)
		{
			increased++;
			cout << "(increased)";
		}
		else if (depth < last)
		{
			decreased++;
			cout << "(decreased)";
		}
		else
		{
			cout << "(equal)";
		}
		cout << endl;

		last = depth;
	}

	cout << "Increased: " << increased << endl;
	cout << "Decreased: " << decreased << endl;

	return 0;
}
