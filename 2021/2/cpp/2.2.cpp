#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	string dir;
	int dist;
	int aim = 0;
	int h=0, d=0; // h = horizontal, d = depth

	while (input >> dir >> dist)
	{
		if (dir.compare("forward") == 0)
		{
			h += dist;
			d += aim * dist;
			
			cout << "Moving Forward " << dist << endl;
			cout << "\tTraveled to depth " << d << endl;
		}
		else if (dir.compare("up") == 0)
		{
			cout << "Aiming Up " << dist << endl;
			aim -= dist;
		}
		else if (dir.compare("down") == 0)
		{
			cout << "Aiming Down " << dist << endl;
			aim += dist;
		}
		else
		{
			cerr << "Warning: Unexpected direction" << endl;
		}

		cout << h << ", " << d << " aim: " << aim << endl;
	}

	cout << "Result: " << h << " Horizontal * " << d << " Depth = " << h * d << endl;

	return 0;
}
