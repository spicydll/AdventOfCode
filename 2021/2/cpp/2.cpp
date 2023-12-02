#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	string dir;
	int dist;
	int h=0, d=0; // h = horizontal, d = depth

	while (input >> dir >> dist)
	{
		if (dir.compare("forward") == 0)
		{
			cout << "Moving Forward " << dist << endl;
			h += dist;
		}
		else if (dir.compare("up") == 0)
		{
			cout << "Moving Up " << dist << endl;
			d -= dist;
		}
		else if (dir.compare("down") == 0)
		{
			cout << "Moving Down " << dist << endl;
			d += dist;
		}
		else
		{
			cerr << "Warning: Unexpected direction" << endl;
		}

		cout << h << ", " << d << endl;
	}

	cout << "Result: " << h << " Horizontal * " << d << " Depth = " << h * d << endl;

	return 0;
}
