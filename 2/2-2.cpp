#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>

using namespace std;


vector<int> split(string s)
{
    vector<int> data;
    istringstream stream(s);
    int value;
    while (stream >> value)
        data.push_back(value);
    return data;
}

bool issafe(vector<int> data)
{
    bool ret{true};

    if (data.size() >= 2) {
        auto sign = data[1] - data[0];
        if (!sign)
            return false;
        sign /= abs(sign);

        for (int i = 0; ret && i < data.size() - 1; ++i) {
            auto delta = (data[i+1]-data[i]) / sign;
            ret = (delta >= 1 && delta <= 3);
        }

    }
    return ret;
}

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;

    int safe{0};

	while(!input.eof()) {
        string s;
	    getline(input, s);
	    if (!s.length())
	        break;
	    auto data = split(s);
	    if (issafe(data))
	        ++safe;
	    else
            for (int i = 0; i < data.size(); ++i) {
                auto temp = data;
                temp.erase(temp.begin()+i);
                if (issafe(temp)) {
                    ++safe;
                    break;
                }
            }
	}

	cout << safe << endl;
}
