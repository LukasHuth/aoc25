#include <cstdint>
#include <fstream>
#include <iostream>
#include <queue>
#include <stdlib.h>
#include <string>
#include <tuple>
#include <vector>

class Machine {
private:
  uint32_t expected_lights;
  std::vector<uint32_t> buttonWiring;
  std::vector<int> joltageRequirements;

public:
  uint32_t findMoves();
  Machine(std::string);
};

void part1() {
  std::ifstream InputFile("input.txt");
  std::string input;
  std::vector<Machine> machines;
  while(std::getline(InputFile, input)) {
    machines.push_back(Machine(input));
  }
  uint32_t result = 0;
  for(auto machine : machines) {
    result += machine.findMoves();
  }
  std::cout << result << std::endl;
}

void part2() {}

int main(int argc, char **argv) {
  if (argc >= 2 && *argv[1] == '2') {
    part2();
  } else {
    part1();
  }
  return 0;
}

uint32_t Machine::findMoves() {
  // std::cout << "start find move" << std::endl;
  uint32_t result = 0;
  // state, modification, depth
  std::queue<std::tuple<uint32_t, uint32_t, uint32_t>> moves;
  for (uint32_t modification : this->buttonWiring) {
    moves.push({0, modification, 1});
  }
  while (!moves.empty()) {
    std::tuple<uint32_t, uint32_t, uint32_t> entry = moves.front();
    moves.pop();
    uint32_t state = std::get<0>(entry);
    uint32_t modifier = std::get<1>(entry);
    uint32_t depth = std::get<2>(entry);
    // std::cout << "state: " << state << " modifier: " << modifier << " depth: " << depth << std::endl;
    state ^= modifier;
    if(state == this->expected_lights) return depth;
    depth++;
    for (uint32_t modification : this->buttonWiring) {
      moves.push({state, modification, depth});
    }
  }
  return result;
}

uint32_t getButtonMask(std::string button) {
  uint32_t result = 0;
  std::string light;
  int32_t comma_split = button.find(',');
  while (comma_split > -1) {
    light = button.substr(0, comma_split);
    uint8_t pos = std::stoi(light);
    result |= 1 << pos;
    button = button.substr(comma_split + 1);
    comma_split = button.find(',');
  }
  uint8_t pos = std::stoi(button);
  result |= 1 << pos;
  return result;
}

Machine::Machine(std::string input) {
  int32_t light_split = input.find(' ');
  std::string lights = input.substr(0, light_split);
  int32_t joltage_split = input.find_last_of(' ');
  std::string buttons = input.substr(light_split + 1, joltage_split - light_split - 1);
  std::string joltage = input.substr(joltage_split);
  this->expected_lights = 0;
  uint8_t i = 0;
  for(char c : lights) {
    if(c != '.' && c != '#') continue;
    if(c == '#'){
      this->expected_lights |= 1 << i;
    }
    i++;
  }
  int32_t space_split = buttons.find(' ');
  std::string button;
  while(space_split > -1) {
    button = buttons.substr(1, space_split-1);
    buttons = buttons.substr(space_split + 1);
    this->buttonWiring.push_back(getButtonMask(button));
    space_split = buttons.find(' ');
  }
  button = buttons.substr(1, buttons.length() - 2);
  this->buttonWiring.push_back(getButtonMask(button));
}
