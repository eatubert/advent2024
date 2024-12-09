#include <iostream>
#include <fstream>
#include <string>
#include <regex>

using namespace std;

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;
    regex mul_regex(R"(mul\((\d+),(\d+)\))");

    int total{0};
    string s;
    while (input >> s) {
        for (sregex_iterator i = sregex_iterator(s.begin(), s.end(), mul_regex); i != sregex_iterator(); ++i) {
             smatch match = *i;
             total += stoi(match[1]) * stoi(match[2]);
        }
    }

    cout << total << endl;
}