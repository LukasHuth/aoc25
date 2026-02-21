#include <algorithm>
#include <array>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <queue>
#include <stdlib.h>
#include <string>
#include <string_view>
#include <tuple>
#include <unordered_set>
#include <vector>

#define JoltageSize 10
typedef std::array<uint32_t, JoltageSize> JoltageMeter;

class Machine {
private:
  uint32_t expected_lights;
  std::vector<uint32_t> buttonWiring;
  JoltageMeter joltageRequirements;

public:
  uint32_t findJoltageButtons();
  uint32_t findMoves();
  Machine(std::string_view);
};

void part1() {
  std::ifstream InputFile("input.txt");
  std::string input;
  std::vector<Machine> machines;
  while (std::getline(InputFile, input)) {
    machines.push_back(Machine(input));
  }
  uint32_t result = 0;
  for (auto machine : machines) {
    result += machine.findMoves();
  }
  std::cout << result << std::endl;
}

void part2() {
  std::ifstream InputFile("input.txt");
  std::string input;
  std::vector<Machine> machines;
  while (std::getline(InputFile, input)) {
    machines.push_back(Machine(input));
  }
  uint32_t result = 0;
  for (auto machine : machines) {
    result += machine.findJoltageButtons();
  }
  std::cout << result << std::endl;
}

int main(int argc, char **argv) {
  if (argc >= 2 && *argv[1] == '2') {
    part2();
  } else {
    part1();
  }
  return 0;
}

struct TupleHash {
  std::size_t
  operator()(const std::tuple<uint32_t, uint32_t, uint32_t> &t) const {
    auto [a, b, c] = t;

    std::size_t h1 = std::hash<unsigned>{}(a);
    std::size_t h2 = std::hash<unsigned>{}(b);
    std::size_t h3 = std::hash<unsigned>{}(c);

    // Good hash combine
    std::size_t seed = h1;
    seed ^= h2 + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    seed ^= h3 + 0x9e3779b9 + (seed << 6) + (seed >> 2);

    return seed;
  }
};

struct TupleHashJoltage {
  std::size_t operator()(const JoltageMeter &t) const {
    uint32_t a = t.at(0);
    std::size_t h1 = std::hash<uint32_t>{}(a);
    std::size_t seed = h1;
    for (uint8_t i = 1; i < JoltageSize; i++) {
      uint32_t v = t.at(i);
      std::size_t h = std::hash<unsigned>{}(v);
      seed ^= h + 0x9e3779b9 + (seed << 6) + (seed >> 2);
    }

    return seed;
  }
};

uint32_t Machine::findJoltageButtons() {
  std::unordered_set<JoltageMeter, TupleHashJoltage> lookup_set;
  uint32_t result = 0;
  std::queue<std::tuple<JoltageMeter, uint32_t, uint32_t>> moves;
  lookup_set.insert(JoltageMeter());
  for (uint32_t modification : this->buttonWiring) {
    moves.push({JoltageMeter(), modification, 1});
  }
  while (!moves.empty()) {
    std::tuple<JoltageMeter, uint32_t, uint32_t> entry = moves.front();
    moves.pop();
    JoltageMeter state = std::get<0>(entry);
    uint32_t modifier = std::get<1>(entry);
    uint32_t depth = std::get<2>(entry);
    JoltageMeter newState;
    bool invalid = false;
    for (uint8_t i = 0; i < JoltageSize; i++) {
      newState[i] = state[i] + ((modifier >> i) & 1);
      if (newState[i] > this->joltageRequirements[i])
        invalid = true;
    }
    if (invalid)
      continue;
    state = newState;
    if (state == this->joltageRequirements)
      return depth;
    depth++;
    if (!lookup_set.insert(state).second)
      continue;
    for (uint32_t modification : this->buttonWiring) {
      moves.push({state, modification, depth});
    }
  }
  return result;
}

uint32_t Machine::findMoves() {
  std::unordered_set<std::tuple<uint32_t, uint32_t, uint32_t>, TupleHash>
      lookup_set;
  // std::cout << "start find move" << std::endl;
  uint32_t result = 0;
  // state, modification, depth
  std::queue<std::tuple<uint32_t, uint32_t, uint32_t>> moves;
  for (uint32_t modification : this->buttonWiring) {
    lookup_set.insert({0, modification, 1});
    moves.push({0, modification, 1});
  }
  while (!moves.empty()) {
    std::tuple<uint32_t, uint32_t, uint32_t> entry = moves.front();
    moves.pop();
    uint32_t state = std::get<0>(entry);
    uint32_t modifier = std::get<1>(entry);
    uint32_t depth = std::get<2>(entry);
    // std::cout << "state: " << state << " modifier: " << modifier << " depth:
    // " << depth << std::endl;
    state ^= modifier;
    if (state == this->expected_lights)
      return depth;
    depth++;
    for (uint32_t modification : this->buttonWiring) {
      if (!lookup_set.insert({state, modification, depth}).second)
        continue;
      moves.push({state, modification, depth});
    }
  }
  return result;
}

uint32_t getButtonMask(std::string_view button) {
  uint32_t result = 0;
  while (!button.empty()) {
    size_t pos = button.find(',');
    std::string_view target = button.substr(0, pos);
    uint8_t offset = std::stoi(std::string(target));
    result |= 1 << offset;
    if (pos == std::string_view::npos)
      break;
    button.remove_prefix(pos + 1);
  }
  return result;
}

JoltageMeter getJoltageValues(std::string_view button) {
  uint32_t result = 0;
  uint32_t meterValues[JoltageSize] = {0};
  uint8_t i = 0;
  while (!button.empty()) {
    size_t pos = button.find(',');
    std::string_view target = button.substr(0, pos);
    uint32_t value = std::stoi(std::string(target));
    meterValues[i++] = value;
    if (pos == std::string_view::npos)
      break;
    button.remove_prefix(pos + 1);
  }
  JoltageMeter joltageMeter;
  std::copy(std::begin(meterValues), std::end(meterValues),joltageMeter.begin());
  return joltageMeter;
}

Machine::Machine(std::string_view input) {
  int32_t light_split = input.find(' ');
  std::string_view lights = input.substr(0, light_split);
  int32_t joltage_split = input.find_last_of(' ');
  std::string_view buttons =
      input.substr(light_split + 1, joltage_split - light_split - 1);
  std::string_view joltage = input.substr(joltage_split);
  joltage.remove_prefix(2);
  joltage.remove_suffix(1);
  this->expected_lights = 0;
  uint8_t i = 0;
  for (char c : lights) {
    if (c != '.' && c != '#')
      continue;
    if (c == '#') {
      this->expected_lights |= 1 << i;
    }
    i++;
  }
  while (!buttons.empty()) {
    size_t pos = buttons.find(' ');
    this->buttonWiring.push_back(getButtonMask(buttons.substr(1, pos - 1)));
    if (pos == std::string_view::npos)
      break;
    buttons.remove_prefix(pos + 1);
  }
  this->joltageRequirements = getJoltageValues(joltage);
}
