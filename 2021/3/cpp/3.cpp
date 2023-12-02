#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	string line;
	int linelen;
	int numlines = 1;
	int i;
	string gamma = "";
	string epsilon = "";
	int g, e;
	
	input >> line;
	linelen = line.size();
	int num1[linelen];
	
	for (i = 0; i < linelen; i++)
		num1[i] = 0;

	do
	{
		numlines++;
		for (i = 0; i < linelen; i++)
		{
			if (line.at(i) == '1')
				num1[i]++;
		}
		
	} 
	while (input >> line);

	for (i = 0;	i < linelen; i++)
	{
		if (num1[i] > numlines / 2)
		{
			gamma.append("1");
			epsilon.append("0");
		}
		else
		{
			gamma.append("0");
			epsilon.append("1");
		}
	}

	g = stoi(gamma, 0, 2);
	e = stoi(epsilon, 0, 2);

	cout << "  Gamma: " << g << endl;
	cout << "Epsilon: " << e << endl;
	cout << "  Total: " << g * e << endl;

	return 0;
}
