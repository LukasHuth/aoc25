fn main() {
    let part = std::env::args().skip(1).next().unwrap_or("1".to_string());
    match part.as_str() {
        "1" => part1::part1(),
        "2" => part2::part2(),
        _ => panic!("please select part 1 or 2"),
    }
}
mod part1;
mod part2;
mod utils;
