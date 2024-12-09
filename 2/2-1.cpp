#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;


vector<int> split(string s)
{
    vector<int> data{};
    istringstream stream(s);
    int value;
    while (stream >> value)
        data.push_back(value);
    return data;
}

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;

    int safe{0};

	while(!input.eof()) {
        string s{};
	    getline(input, s);
	    if (!s.length())
	        break;
	    auto data = split(s);

        bool issafe{true};

	    if (data.size() >= 2) {
            auto sign = data[1] - data[0];
            if (!sign)
                continue;
            sign /= abs(sign);

            for (int i = 0; issafe && i < data.size() - 1; ++i) {
                auto delta = (data[i+1]-data[i]) / sign;
                issafe = (delta >= 1 && delta <= 3);
            }

        }
        if (issafe)
            ++safe;
	}

	cout << safe << endl;
}
