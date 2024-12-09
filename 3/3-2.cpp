#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;
    regex mul_regex(R"(mul\((\d+),(\d+)\))");
    regex master_regex(R"((mul\(\d+,\d+\)|do\(\)|don't\(\)))");

    int total{0}, state{1};
    string s;
    while (input >> s) {
        for (auto i = sregex_iterator(s.begin(), s.end(), master_regex); i != sregex_iterator(); ++i) {
            string match = i->str();
             if (match == "do()"s)
                state = 1;
             if (match == "don't()"s)
                state = 0;
             if (state && regex_search(match, mul_regex)) {
                 smatch m = *sregex_iterator(match.begin(), match.end(), mul_regex);
                 total += stoi(m[1]) * stoi(m[2]);
             }
        }
    }

    cout << total << endl;
}