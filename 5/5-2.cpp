#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <unordered_set>
#include <sstream>


void readInput(char *fname, std::unordered_set<std::string>& rules, std::vector<std::string>& updates)
{
    std::ifstream file;
    if (fname) {
        file = std::ifstream{fname};
        if (!file.is_open()) {
            std::cout << "Can't open " << fname << std::endl;
            exit(1);
        }
    }
    std::istream& input = fname ? file : std::cin;

    std::string line;
    while (getline(input,line)) {
        if (line.empty())
            break;
        rules.insert(line);
    }

    while (getline(input,line)) {
        if (line.empty())
            break;
        updates.push_back(line);
    }
}

std::vector<std::string> splitPages(std::string update)
{
    std::vector<std::string> pages;
    std::stringstream ss(update);
    std::string page;
    while (getline(ss, page, ','))
        pages.push_back(page);
    return pages;
}


bool checkPagesOrdered(const std::vector<std::string>& pages, const std::unordered_set<std::string>& rules)
{
    for (size_t i = 0; i < pages.size()-1; ++i) {
        for (size_t j = i+1; j < pages.size(); ++j) {
            std::string rule = pages[i] + "|" + pages[j];
            if (rules.find(rule) == rules.end())
                return false;
        }
    }
    return true;
}


bool checkCandidateOrdered(const std::string& candidate, const std::unordered_set<std::string>& others, const std::unordered_set<std::string>& rules)
{
    for (const auto& other: others) {
        std::string rule = candidate + "|" + other;
        if (rules.find(rule) == rules.end())
            return false;
    }
    return true;
}


int main(int argc, char* argv[])
{
    std::unordered_set<std::string> rules;
    std::vector<std::string> updates;
    readInput(argc > 1 ? argv[1] : nullptr, rules, updates);

    int total{0};
    for (const auto& update: updates) {
        std::vector<std::string> pages = splitPages(update);
        if (!checkPagesOrdered(pages, rules)) {
            std::vector<std::string> orderedPages;
            std::unordered_set<std::string> pendingSet(pages.begin(), pages.end());

            for (size_t i = 0; i < pages.size(); ++i) {
                for (const auto& candidate: pendingSet) {
                    std::unordered_set<std::string> others;
                    for (auto& item: pendingSet)
                        if (item != candidate)
                            others.insert(item);

                    if (checkCandidateOrdered(candidate, others, rules)) {
                        orderedPages.push_back(candidate);
                        pendingSet.erase(candidate);
                        break;
                    }
                }
            }

            if (pendingSet.size())
                std::cout << "No answer for " << update << std::endl;
            else if (!orderedPages.empty()) {
                // Get the middle page (median of ordered pages)
                total += stoi(orderedPages[(orderedPages.size()+1)/2-1]);
            }
        }
    }

    std::cout << total << std::endl;
    return 0;
}

