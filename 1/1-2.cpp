#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <algorithm>

using namespace std;

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;
    vector<int> a{};
    map<int,int> b{};

	int vala{}, valb{};
	while (input >> vala >> valb) {
		a.push_back(vala);
		b[valb]++;
	}

    int total{0};
    for (auto aa: a)
        total += aa * b[aa];

    cout << total << endl;
}

