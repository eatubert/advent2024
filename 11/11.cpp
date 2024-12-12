#include <iostream>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <map>
#include <utility>
#include <cmath>

using cacheType = std::map<std::pair<int64_t, int>, int64_t>;

std::vector<int64_t> step(int64_t num)
{
    if (!num)
        return {1};
    int digits = static_cast<int>(log10(num)) + 1;
    if ((digits % 2) == 0) {
        int64_t half = static_cast<int64_t>(pow(10, digits / 2));
        return {
            num / half,
            num % half,
        };
    }
    return {num * 2024};
}

int64_t walkTree(int64_t actual, int round, cacheType& cache)
{
    if (!round)
        return 1;
    int64_t total{0};
    for (auto num: step(actual)) {
        std::pair<int64_t, int> key = {num, round};
        auto old = cache.find(key);
        if (old != cache.end()) {
            total += old->second;
        } else {
            int64_t val = walkTree(num, round-1, cache);
            cache[key] = val;
            total += val;
        }
    }

    return total;
}


int64_t processInput(std::istream& input, int rounds)
{
    int64_t total{0};
    int64_t val;
    cacheType cache;
	while (input >> val) {
	    total += walkTree(val, rounds, cache);
	}
	return total;
}



int64_t  readInput(char *fname, int rounds)
{
    std::ifstream file;
    if (fname) {
        file = std::ifstream{fname};
        if (!file) {
            std::cerr << "Can't open " << fname << std::endl;
            return -1;
        }
    }
    std::istream& input = fname ? file : std::cin;
    return processInput(input, rounds);
}


int main(int argc, char* argv[])
{
    int rounds = -1;

    if (argc > 1)
        rounds = atoi(argv[1]);

    if (rounds <= 0) {
        std::cerr << argv[0] << " [rounds] [filename | stdin]";
        return 1;
    }

    int64_t total = readInput(argc > 2 ? argv[2] : nullptr, rounds);
    if (total < 0)
        return 1;

    std::cout << total << std::endl;
    return 0;
}

