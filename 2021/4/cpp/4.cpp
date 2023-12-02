#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>

using namespace std;

vector<vector<int>> get_cols(vector<vector<int>> board)
{
	int i, j;
	vector<vector<int>> col_board;

	for (i = 0; i < board.size(); i++)
	{
		col_board.push_back(new vector<int>());
	}

	for (i = 0; i < board.size(); i++)
	{
		for (j = 0; j < board.size(); j++)
		{
			col_board.at(j).push_back(board.at(j).at(i));
		}
	}

	return col_board;
}

int test_row(vector<int> row, vector<int> calls, int limit)
{
	int i;
	int high = 0;
	int *ind;

	for (i = 0; i < row.size(); i++)
	{
		ind = find(calls.begin(), calls.end(), row.at(i));
		
		if (ind == calls.end() || &ind > limit)
			return -1;
		else if (&ind > high)
			high = &ind;
	}

	return high;
}

int test_win(vector<vector<int>> board, vector<int> calls, int limit)
{
	int i;
	int winat = -1;
	int rowwin;

	for (i = 0; i < board.size(); i++)
	{
		rowwin = test_row(board.at(i), calls, limit);

		if (rowwin != -1 && (winat == -1 || winat > rowwin))
			winat = rowwin;
	}

	return winat;
}

vector<vector<int>> read_board(ifstream input)
{
	int i, j;
	vector<vector<int>> board;
	int num;

	for (i = 0; i < 5; i++)
	{
		board.push_back(new vector<int>());

		for (j = 0; j < 5; j++)
		{
			if (!(input >> num))
				return NULL;

			board.at(i).push_back(num);
		}
	}

	for (i = 0; i < 5; i++)
	{
		board.push_back(new vector<int>());
		
		for (j = 0; j < 5; j++)
		{
			board.at(i + 5).push_back(board.at(j).at(i));
		}
	}

	return board;
}

int main(int argc, char *argv[])
{
	ifstream input("input");
	string line;
	vector<int> calls;
	int num;
	int i, j;
	vector<vector<int>> board;
	vector<int> winboard;
		
	getline(input, line);
	istringstream iss(line);
	
	while (iss >> num)
	{
		calls.push_back(num);
	}
	
	while (read_board(input))
	{
		
	}

	return 0;
}
