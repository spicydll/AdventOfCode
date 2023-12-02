#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	int wdepth = 0;
	int wlast = 0;
	queue<int> removeq;
	int in, i;
	int increased = 0;
	int decreased = 0;

	for (i = 0; i < 3; i++)
	{
		input >> in;
		removeq.push(in);
		wlast += in;
	}

	wdepth = wlast;

	cout << wlast << " (N/A - no previous sum)" << endl;
	while (input >> in)
	{
		removeq.push(in);
		wdepth -= removeq.front();
		removeq.pop();
		wdepth += in;
		cout << wdepth << " ";
		if (wdepth > wlast)
		{
			increased++;
			cout << "(increased)";
		}
		else if (wdepth < wlast)
		{
			decreased++;
			cout << "(decreased)";
		}
		else
		{
			cout << "(equal)";
		}
		cout << endl;

		wlast = wdepth;
	}

	cout << "Increased: " << increased << endl;
	cout << "Decreased: " << decreased << endl;

	return 0;
}
