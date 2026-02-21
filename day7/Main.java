import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;

public class Main {
  public static void main(String[] args) {
    if (args.length >= 1 && args[0].equals("2")) {
      Main.part2();
    } else {
      Main.part1();
    }
  }

  private static void part1() {
    ArrayList<String> lines = readLines();
    Board board = new Board(lines);
    while (!board.isFinished()) {
      board.next();
    }
    System.out.printf("%d\n", board.happenedSplits);
  }

  private static void part2() {
    ArrayList<String> lines = readLines();
    Board board = new Board(lines);
    int start = (int) board.beams.toArray()[0];
    long timelines = board.countTimelines(start, 0);
    System.out.printf("%d\n", timelines);
  }

  private static ArrayList<String> readLines() {
    try {
      File file = new File("input.txt");
      FileReader reader = new FileReader(file);
      ArrayList<String> lines = new ArrayList<>(reader.readAllLines());
      reader.close();
      return lines;
    } catch (FileNotFoundException e) {
      System.err.println("input file not found");
      System.exit(1);
    } catch (IOException e) {
      System.err.println("failed to read input file");
      System.exit(1);
    }
    return new ArrayList<>();
  }

  private static class Board {
    private HashSet<Integer> beams = new HashSet<>();
    private Boolean[][] splitters;
    private int currentLine = 0;
    private int gridSize = 0;
    private long happenedSplits = 0;
    private Long[][] lookup_table;

    public Board(ArrayList<String> lines) {
      this.lookup_table = new Long[lines.size()][lines.get(0).length()];
      for (int i = 0; i < lines.get(0).length(); i++) {
        if (lines.get(0).charAt(i) != 'S')
          continue;
        this.beams.add(i);
      }
      this.gridSize = lines.get(0).length();
      this.splitters = lines.stream().skip(1)
          .map(line -> line.chars().mapToObj(c -> c == '^').toArray(Boolean[]::new)).toArray(Boolean[][]::new);
    }

    public void next() {
      HashSet<Integer> old_beams = (HashSet<Integer>) this.beams.clone();
      this.beams.clear();
      for (int beam : old_beams) {
        if (this.splitters[this.currentLine][beam]) {
          this.happenedSplits++;
          if (beam - 1 >= 0) {
            this.beams.add(beam - 1);
          }
          if (beam + 1 < gridSize) {
            this.beams.add(beam + 1);
          }
        } else {
          this.beams.add(beam);
        }
      }
      this.currentLine++;
    }

    public boolean isFinished() {
      return this.splitters.length <= this.currentLine;
    }

    public long countTimelines(int beamPos, int lineDepth) {
      if (this.lookup_table[lineDepth][beamPos] != null)
        return this.lookup_table[lineDepth][beamPos];
      if (lineDepth >= this.splitters.length)
        return 1;
      if (this.splitters[lineDepth][beamPos]) {
        long result = 0;
        if (beamPos - 1 >= 0) {
          result += this.countTimelines(beamPos - 1, lineDepth);
        }
        if (beamPos + 1 < this.gridSize) {
          result += this.countTimelines(beamPos + 1, lineDepth);
        }
        this.lookup_table[lineDepth][beamPos] = result;
        return result;
      } else {
        long result = this.countTimelines(beamPos, lineDepth + 1);
        this.lookup_table[lineDepth][beamPos] = result;
        return result;
      }
    }
  }
}
