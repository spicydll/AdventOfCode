#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	string line;
	vector<string> lines;
	vector<string> oxygen;
	vector<string> zeroes;
	vector<string> ones;
	vector<string> co2;
	int i, j;
	int oxy, co;

	while (input >> line)
		lines.push_back(line);

	// Oxygen 
	oxygen = lines;
	for (i = 0; i < oxygen.at(0).size() && oxygen.size() > 1; i++)
	{
		zeroes.clear();
		ones.clear();
		for (j = 0; j < oxygen.size(); j++)
		{
			if (oxygen.at(j).at(i) == '1')
				ones.push_back(oxygen.at(j));
			else
				zeroes.push_back(oxygen.at(j));
		}

		if (ones.size() >= zeroes.size())
			oxygen = ones;
		else
			oxygen = zeroes;
	}

	oxy = stoi(oxygen.at(0), 0, 2);
	
	// c02

	co2 = lines;
	for (i = 0; i < co2.at(0).size() && co2.size() > 1; i++)
	{
		zeroes.clear();
		ones.clear();
		for (j = 0; j < co2.size(); j++)
		{
			if (co2.at(j).at(i) == '1')
				ones.push_back(co2.at(j));
			else
				zeroes.push_back(co2.at(j));
		}

		if (ones.size() < zeroes.size())
			co2 = ones;
		else
			co2 = zeroes;
	}

	co = stoi(co2.at(0), 0, 2);
	
	cout << " Oxygen rate: " << oxy << endl;
	cout << "    CO2 rate: " << co << endl;
	cout << "Life Support: " << oxy * co << endl;

	return 0;
}
