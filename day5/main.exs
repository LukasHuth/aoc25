defmodule AOC do
  def run() do
    args = System.argv()
    case args do
      [first | _rest] ->
        case first do
          "2" -> part2()
          _ -> part1()
        end
      [] -> IO.puts("No arguments provided")
    end
  end
  def part1() do
    {freshIngredients, availableIngredients} = readInput() |> processInput()
    availableIngredients 
    |> Enum.filter(fn ingredientId -> isFresh(ingredientId, freshIngredients) end) 
    |> Enum.count()
    |> IO.puts()
  end
  def isFresh(ingredientId, freshIngredients) do
    freshIngredients |> Enum.any?(fn {range_start, range_end} -> ingredientId >= range_start && ingredientId <= range_end end)
  end
  def part2() do
    readInput() 
    |> processInput() 
    |> then(fn {freshIngredients, _} -> freshIngredients end)
    |> Enum.sort(&(&1 |> elem(0) <= &2 |> elem(0)))
    |> Enum.reduce([], fn item, acc ->
      case acc do
        [] -> [item]
        [last | rest] ->
          if can_join?(last, item) do
            [{last |> elem(0), max(last |> elem(1), item |> elem(1)) } | rest]
          else
            [item | acc]
          end
      end
    end)
    |> Enum.map(fn {range_start, range_end} -> 
      range_end - range_start + 1
    end)
    |> Enum.sum()
    |> IO.puts()
  end
  def can_join?(a, b) do
    a |> elem(1) >= b |> elem(0)
  end
  def readInput() do
    case File.read("input.txt") do
      {:ok, content} -> content
      {:error, reason} -> raise "Failed to read file: #{reason}"
    end
  end
  def processInput(filecontent) do
    filecontent
    |> String.trim()
    |> String.split("\n\n")
    |> then(fn [freshIngredients, availableIngredients] ->
      {parseFreshIngredients(freshIngredients), parseAvailableIngredients(availableIngredients)}
    end)
  end
  def parseFreshIngredients(freshIngredientsString) do
    freshIngredientsString
    |> String.split("\n")
    |> Enum.map(fn chunk ->
      [range_start, range_end] = String.split(chunk, "-")
      {String.to_integer(range_start), String.to_integer(range_end)}
    end)
  end
  def parseAvailableIngredients(availableIngredientsString) do
    availableIngredientsString
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn str -> String.to_integer(str) end)
  end
end

AOC.run()
