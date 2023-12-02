#include <iostream> 
#include <string>
#include <stack>
#include <fstream>
#include <vector>
#include <algorithm>

using namespace std;

long get_completion_score(stack<char> chunkstack, int lnum)
{
	char cur;
	string completion;
	long score = 0;

	for (;chunkstack.size() > 0; chunkstack.pop())
	{
		cur = chunkstack.top();
		score *= 5;
		switch (cur)
		{
			case '(': completion.append(")"); score += 1; break;
			case '[': completion.append("]"); score += 2; break;
			case '{': completion.append("}"); score += 3; break;
			case '<': completion.append(">"); score += 4; break;
		}
	}
	
	cout << "[" << lnum << "] Completion: \"" << completion << "\" score: " << score << endl;

	return score; 
}

int get_score(string line, int lnum, long &comscore)
{
	stack<char> chunkstack;
	int i;
	char open;
	int score;
	
	for (i = 0; i < line.size(); i++)
	{
		open = '!';
		switch (line.at(i))
		{
			case '(':
			case '[':
			case '{':
			case '<':
			{
				chunkstack.push(line.at(i));
				break;		
			}
			case ')': open = '('; score = 3; break;
			case ']': open = '['; score = 57; break;
			case '}': open = '{'; score = 1197; break;
			case '>': open = '<'; score = 25137; break;
			default: cout << "[" << lnum << ":" << i + 1 << "] Unexpected token: '" << line.at(i) << "'" << endl; return -2;
		}

		if (open != '!')
		{
			if (chunkstack.top() == open)
			{
				chunkstack.pop();
			}
			else
			{
				cout << "[" << lnum << ":" << i + 1 << "] Expected '" << chunkstack.top() << "', but found '" << line.at(i) << "' instead. Score = " << score << endl;
				return score;
			}
		}
	}

	if (chunkstack.size() > 0)
	{
		cout << "[" << lnum << ":" << i + 1 << "] Line ended without closing '" << chunkstack.top() << "' chunk." << endl;
		comscore = get_completion_score(chunkstack, lnum);
		return -1;
	}
	else
	{
		cout << "[" << lnum << "] Valid syntax.";
		return 0;
	}
}

long get_mid_score(vector<long> scores)
{
	sort(scores.begin(), scores.end());

	return scores.at(scores.size() / 2);
}

int main(int argc, char *argv[])
{
	string line;
	int result;
	int score = 0;
	ifstream inputfile("input");
	int i = 1;
	long comscore;
	vector<long> comscores;

	while (getline(inputfile, line))
	{
		result = get_score(line, i, comscore);
		
		if (result > 0)
		{
			score += result;
		}
		else if (result == -1)
		{
			comscores.push_back(comscore);
		}

		i++;
	}

	cout << "Score: " << score << endl;
	cout << "Completion Mid score: " << get_mid_score(comscores) << endl;
	
	return 0;
}
