#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>

void processInput(std::istream& input, std::vector<int>& first, std::vector<int>& second)
{
	int val1, val2;
	while (input >> val1 >> val2) {
		first.push_back(val1);
		second.push_back(val2);
	}
}



void readInput(char *fname, std::vector<int>& first, std::vector<int>& second)
{
    std::ifstream file;
    if (fname) {
        file = std::ifstream{fname};
        if (!file) {
            std::cerr << "Can't open " << fname << std::endl;
            exit(1);
        }
    }
    std::istream& input = fname ? file : std::cin;
    processInput(input, first, second);
}



int main(int argc, char* argv[])
{
    std::vector<int> first, second;
    readInput(argc > 1 ? argv[1] : nullptr, first, second);

    std::sort(first.begin(), first.end());
    std::sort(second.begin(), second.end());

    int total{0};
    for (size_t i = 0; i < first.size(); ++i)
        total += abs(first[i] - second[i]);

    std::cout << total << std::endl;
    return 0;
}

