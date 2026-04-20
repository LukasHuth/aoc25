use crate::{
    part2::{count_possible_ways, topo_sort},
    utils::{Component, ServerRack, FILE},
};

pub fn part1() {
    let result = part1_int();
    println!("{result}");
}
fn part1_int() -> u64 {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let start = server_rack.find_start();
    // let result = server_rack.find_path(start, 0, 0, Visited::new(), &mut HashMap::new());
    let neigbours = server_rack
        .components
        .iter()
        .map(|c| match c {
            Component::End => vec![],
            Component::Start(c) | Component::Node(c) => c.clone(),
        })
        .collect();
    let topo = topo_sort(server_rack.components.len(), &neigbours);
    let result = count_possible_ways(start, 0, &topo, &neigbours);
    result
}
#[test]
fn test_part1() {
    assert_eq!(part1_int(), 585);
}
