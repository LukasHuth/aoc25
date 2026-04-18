use std::collections::{HashMap, HashSet, VecDeque};

use crate::utils::{Component, ServerRack, Visited, FILE};

pub fn part2() {
    let server_rack: ServerRack = FILE.parse().unwrap();
    // let dac_connections = get_connections(&server_rack, "dac");
    // let fft_connections = get_connections(&server_rack, "fft");
    // println!(
    //     "{} {} {}",
    //     svr_connections.len(),
    //     dac_connections.len(),
    //     fft_connections.len()
    // );
    let start = server_rack.find_named("svr").unwrap();
    let fft = server_rack.find_named("fft").unwrap();
    let dac = server_rack.find_named("dac").unwrap();
    let end = server_rack.find_named("out").unwrap();
    let fft_dac = explore(&server_rack, start, fft, dac, end);
    let dac_fft = explore(&server_rack, start, dac, fft, end);
    println!("{}", fft_dac + dac_fft);
    // let dac = server_rack_1.find_named("dac").unwrap();
    // let fft = server_rack_1.find_named("fft").unwrap();
    // let a = server_rack_1.find_path(start, fft, 0, Visited::new().mark(dac));
    // println!("a: {a}");
}
fn explore(
    server_rack: &ServerRack,
    start: usize,
    step_1: usize,
    step_2: usize,
    end: usize,
) -> u32 {
    let amount_1 = explore_ways(server_rack, start, step_1, step_2);
    let amount_2 = explore_ways(server_rack, step_1, step_2, end);
    let amount_3 = explore_ways(server_rack, step_2, end, step_1);
    amount_1 * amount_2 * amount_3
}
fn explore_ways(server_rack: &ServerRack, start: usize, end: usize, ignore: usize) -> u32 {
    let explore = server_rack
        .explore(start, end, Visited::new().mark(ignore), &mut HashMap::new())
        .1
        .unmark(ignore);
    let server_rack_1 = server_rack.clone().filter(explore.iter().collect());
    let amount = server_rack_1.find_path(start, end, 0, Visited::new(), &mut HashMap::new());
    println!("amount: {amount}, start {start} end {end} ignore {ignore}");
    amount
}
fn get_connections(server_rack: &ServerRack, name: &str) -> HashSet<usize> {
    let start = server_rack.find_named(name).unwrap();
    println!("start: {start}");
    let mut queue: VecDeque<usize> = VecDeque::new();
    let Component::Node(connections) = server_rack.get_component(start).unwrap() else {
        panic!();
    };
    for &component in connections {
        queue.push_back(component);
    }
    let mut has_connection = HashSet::<usize>::new();
    has_connection.insert(start);
    while !queue.is_empty() {
        let component = unsafe { queue.pop_front().unwrap_unchecked() };
        let component = server_rack.get_component(component).unwrap();
        let (Component::Start(connections) | Component::Node(connections)) = component else {
                continue;
            };
        for &connection in connections {
            if has_connection.insert(connection) {
                queue.push_back(connection);
            }
        }
    }
    has_connection
}
