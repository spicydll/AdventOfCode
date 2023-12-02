#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

using namespace std;

int main(int argc, char *argv[])
{
	ifstream input("input");
	string line;
	string node;
	istringstream iss;
	vector<vector<string>> adj;
	vector<vector<string>> tree; // a "tree"
	string walk;
	int i, j;

	while (getline(input, line))
	{
		adj.push_back(new vector<string>);
		
		iss = new istringstream(line);

		getline(iss, node, '-');
		adj.back().push_back(node);
		
		getline(iss, node);
		adj.back().push_back(node);		
	}

	//walk = "start";
	for (i = 0; i < adj.size(); i++)
	{
		if (adj.at(i).front().compare("start") == 0)
		{
			tree.push_back(new vector<string>);
			tree.back().push_back("start");
			tree.back().push_back(adj.at(i).back());
		}
	}

	return 0;
}
