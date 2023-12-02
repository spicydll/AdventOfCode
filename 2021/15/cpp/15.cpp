#include <iostream>
#include <fstream>
#include <vector>
#include <limits>
#include <stack>
#include <algorithm>
#include <string>

using namespace std;

struct coord {
	int x;
	int y;
	
	bool operator ==(const coord& c) const
	{
		return x == c.x && y == c.y;
	}
};

void printPath(vector<vector<int>> nodes, coord **prev)
{
	coord start;
	coord cur;
	vector<string> output;
	string line;
	int i, x, y;

	start.x = 0;
	start.y = 0;

	line = "";
	for (i = 0; i < nodes.at(0).size(); i++)
	{
		line += " ";
	}

	cur.x = nodes.at(0).size() - 1;
	cur.y = y = nodes.size() - 1;
	y++;

	while (!(cur == start))
	{
		if (cur.y < y)
		{
			output.insert(output.begin(), line);
			y--;
		}

		output.front().at(cur.x) = nodes.at(cur.y).at(cur.x) + '0';

		cur = prev[cur.y][cur.x];
	}

	for (i = 0; i < output.size(); i++)
	{
		cout << output.at(i) << endl;
	}
}


int main(int argc, char *argv[])
{
	ifstream input("input");
	vector<vector<int>> nodes;
	string line;
    int i, x, y;
	vector<coord> q;
	coord c;
	int lowc;
	vector<coord> neighbors;
	coord n;
	int alt;
	bool foundtarget = false;
	

	while (getline(input, line))
	{
        nodes.push_back(vector<int>());
		for (i = 0; i < line.size(); i++)
        {
            nodes.back().push_back(line.at(i) - '0');
        }
	}

	int dist[nodes.size()][nodes.at(0).size()];
	coord prev[nodes.size()][nodes.at(0).size()];

	for (y = 0; y < nodes.size(); y++)
	{
		for (x = 0; x < nodes.at(y).size(); x++)
		{
			n.x = -1; // const
			n.y = -1;
			dist[y][x] = numeric_limits<int>::max();
			prev[y][x] = n;
			c.x = x;
			c.y = y;
			q.push_back(c);
		}
	}

	dist[0][0] = 0;

	while (!q.empty())
	{
		lowc = 0;
		for (i = 1; i < q.size(); i++)
		{
			c = q.at(i);
			if (dist[c.y][c.x] < dist[q.at(lowc).y][q.at(lowc).x])
				lowc = i;
		}

		c = q.at(lowc);
		q.erase(q.begin() + lowc);

		cout << "Current coord: " << c.x << ", " << c.y << endl;

		if (c.y == nodes.size() - 1 && c.x == nodes.at(0).size() - 1)
			break;

		neighbors.clear();

		if (c.y > 0)
		{
			n.x = c.x;
			n.y = c.y-1;
			if (find(q.begin(), q.end(), n) != q.end())
			{
				neighbors.push_back(n);
			}
		}

		if (c.y < nodes.size() - 1)
		{
			n.x = c.x;
			n.y = c.y+1;
			if (find(q.begin(), q.end(), n) != q.end())
			{
				neighbors.push_back(n);
			}
		}

		if (c.x > 0)
		{
			n.x = c.x-1;
			n.y = c.y;
			if (find(q.begin(), q.end(), n) != q.end())
			{
				neighbors.push_back(n);
			}
		}

		if (c.y < nodes.at(0).size() - 1)
		{
			n.x = c.x+1;
			n.y = c.y;
			if (find(q.begin(), q.end(), n) != q.end())
			{
				neighbors.push_back(n);
			}
		}

		for (i = 0; i < neighbors.size(); i++)
		{
			n = neighbors.at(i);
			alt = dist[c.y][c.x] + nodes.at(n.y).at(n.x);
			if (alt < dist[n.y][n.x])
			{
				dist[n.y][n.x] = alt;
				prev[n.y][n.x] = c;

				cout << "dist for " << n.x << ", " << n.y << ": " << dist[n.y][n.x] << endl;
			}

		}
	}

	printPath(nodes, prev);
	cout << "Distance to end: " << dist[nodes.size() - 1][nodes.at(0).size() - 1] << endl;

	return 0;
}
