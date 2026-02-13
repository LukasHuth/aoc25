public class Program {
  static int countAdjacent(bool[][] grid, int x, int y)
  {
    int result = 0;
    for (int i = x - 1; i <= x + 1; i++)
    {
      if (i < 0 || i >= grid.Length) continue;
      for (int j = y - 1; j <= y + 1; j++)
      {
        if (j < 0 || j >= grid[i].Length) continue;
        if (j == y && i == x) continue;
        if (!grid[i][j]) continue;
        result++;
      }
    }
    // System.Console.WriteLine($"{x} {y} {result}");
    return result;
  }
  static bool[][] reachable(bool[][] grid) =>
    grid.Select((arr, i) => arr.Select((roll, j) => roll && countAdjacent(grid, i, j) < 4).ToArray())
      .ToArray();

  static int removeRolls(bool[][] grid) {
    bool[][] reachable = Program.reachable(grid);
    int removed = 0;
    for(int i = 0; i < grid.Length; i++) {
      for(int j = 0; j < grid[i].Length; j++) {
        if(!reachable[i][j]) continue;
        removed++;
        grid[i][j] = false;
      }
    }
    return removed;
  }
  
  static bool[][] readGrid() {
    FileStream file = System.IO.File.Open("input.txt", FileMode.Open);
    StreamReader reader = new StreamReader(file);
    string? line;
    List<bool[]> grid = new List<bool[]>();
    while ((line = reader.ReadLine()) != null)
    {
      grid.Add(line.Select(c => c == '@').ToArray());
    }
    return grid.ToArray();
  }

  static void part1()
  {
    bool[][] grid = readGrid();
    System.Console.WriteLine(removeRolls(grid));
  }
  static void Print(List<bool[]> grid)
  {
    foreach (var row in grid)
      Console.WriteLine(string.Join(" ", row.Select(b => b ? "1" : "0")));
  }
  static void Print(bool[][] grid)
  {
    foreach (var row in grid)
      Console.WriteLine(string.Join(" ", row.Select(b => b ? "1" : "0")));
  }

  static void part2()
  {
    bool[][] grid = readGrid();
    int removed;
    int totalRemoved = 0;
    do {
      removed = removeRolls(grid);
      totalRemoved += removed;
    } while(removed > 0);
    System.Console.WriteLine(totalRemoved);
  }

  static void Main(string[] args)
  {
    if (args.Length >= 1 && args[0] == "2") part2();
    else part1();
  }
}
