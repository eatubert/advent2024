#include <iostream>
#include <fstream>
#include <string>
#include <vector>

using namespace std;

void main(int argc, char* argv[])
{
    istream &input = argc > 1 ? static_cast<istream&>(ifstream{argv[1]}) : cin;
    vector<string>lines;
    string s;
    while (input >> s)
        lines.push_back(s);
    int total{0};
    size_t numrows{lines.size()};
    size_t numcolumns{lines[0].length()};
    for (size_t row = 0; row < numrows; ++row)
        for (size_t col = 0; col < numcolumns; ++col) {
            if (lines[row][col] != 'X')
                continue;

            if (col <= numcolumns - 4 &&
                    lines[row][col + 1] == 'M' &&
                    lines[row][col + 2] == 'A' &&
                    lines[row][col + 3] == 'S')
                total += 1;
                
            if (col >= 3 &&
                    lines[row][col - 1] == 'M' &&
                    lines[row][col - 2] == 'A' &&
                    lines[row][col - 3] == 'S')
                total += 1;
    
            if (row <= numrows - 4 &&
                    lines[row + 1][col] == 'M' &&
                    lines[row + 2][col] == 'A' &&
                    lines[row + 3][col] == 'S')
                total += 1;
    
            if (row >= 3 &&
                    lines[row - 1][col] == 'M' &&
                    lines[row - 2][col] == 'A' &&
                    lines[row - 3][col] == 'S')
                total += 1;
    
            if (col <= numcolumns - 4 &&
                    row <= numrows - 4 &&
                    lines[row + 1][col + 1] == 'M' &&
                    lines[row + 2][col + 2] == 'A' &&
                    lines[row + 3][col + 3] == 'S')
                total += 1;
    
            if (col >= 3 &&
                    row >= 3 &&
                    lines[row - 1][col - 1] == 'M' &&
                    lines[row - 2][col - 2] == 'A' &&
                    lines[row - 3][col - 3] == 'S')
                total += 1;
    
            if (col <= numcolumns - 4 &&
                    row >= 3 &&
                    lines[row - 1][col + 1] == 'M' &&
                    lines[row - 2][col + 2] == 'A' &&
                    lines[row - 3][col + 3] == 'S')
                total += 1;
    
            if (col >= 3 &&
                    row <= numrows - 4 &&
                    lines[row + 1][col - 1] == 'M' &&
                    lines[row + 2][col - 2] == 'A' &&
                    lines[row + 3][col - 3] == 'S')
                total += 1;
                
        }

    cout << total << endl;
}
