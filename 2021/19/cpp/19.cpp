#include <iostream>
#include <fstream>
#include <cmath>
#include <vector>
#include <sstream>

using namespace std;

struct coord {
	int x;
	int y;
	int z;

};

int dist(coord c1, coord c2)
{
	return sqrt(pow(c2.x - c1.x, 2) + pow(c2.y - c1.y, 2) + pow(c2.z - c1.z, 2));
}

vector<vector<int>> dist_matrix(vector<coord> scan)
{
	vector<vector<int>> matrix;
	int i, j;

	for (i = 0; i < scan.size(); i++)
	{
		matrix.at(i) = new vector<int>();
		for (j = 0; j < scan.size(); j++)
		{
			if (i == j)
			{
				matrix.at(i).push_back(0);
			}
			else
			{
				matrix.at(i).push_back(dist(scan.at(i), scan.at(j)));
			}
		}
	}
}

void print_matrix(vector<vector<int>> matrix)
{
	int i, j;

	cout << "Scanner " << i << "distance matrix:" << endl;
	for (i = 0; i < matrix.size(); i++)
	{
		for (j = 0; j < matrix.at(i).size(); j++)
		{
			if (j != 0)
				cout << " | ";
			cout << martix.at(i).at(j);
		}
		cout << endl;
	}
}

int disam_beacons(vector<vector<coord>> scans)
{
	vector<vector<vector<int>>> dist_matrices;
	int i,j,k;
	
	for (i = 0; i < scans.size(); i++)
	{
		dist_matrices.push_back(dist_matrix(scans.at(i)));
	}

	
}

int main(int argc, char *argv[])
{
	ifstream input("input");
	string line;

	
	return 0;
}
