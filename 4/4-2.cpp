#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <format>   // c++20

using namespace std;

int main(int argc, char* argv[])
{
    ifstream file;
    if (argc > 1)
        file = ifstream{argv[1]};
    istream &input = argc > 1 ? file : cin;

    vector<string>lines;
    string s;
    while (input >> s)
        lines.push_back(s);
    int total{0};
    size_t numrows{lines.size()};
    size_t numcolumns{lines[0].length()};
    for (size_t row = 1; row < numrows-1; ++row)
        for (size_t col = 1; col < numcolumns-1; ++col) {
            if (lines[row][col] != 'A')
                continue;

            string s1 = format("{}{}", lines[row-1][col-1], lines[row+1][col+1]);
            string s2 = format("{}{}", lines[row-1][col+1], lines[row+1][col-1]);

            if ((s1 == "MS"s || s1 == "SM"s) && (s2 == "MS"s || s2 == "SM"s))
                total += 1;
        }

    cout << total << endl;

    return 0;
}
