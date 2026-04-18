use std::collections::{HashSet, VecDeque};

use crate::utils::{Component, ServerRack, Visited, FILE};

pub fn part2() {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let svr_connections = get_connections(&server_rack, "svr");
    // let dac_connections = get_connections(&server_rack, "dac");
    // let fft_connections = get_connections(&server_rack, "fft");
    // println!(
    //     "{} {} {}",
    //     svr_connections.len(),
    //     dac_connections.len(),
    //     fft_connections.len()
    // );
    let mut server_rack_1 = server_rack;
    server_rack_1.filter(svr_connections);
    let start = server_rack_1.find_named("svr").unwrap();
    let dac = server_rack_1.find_named("dac").unwrap();
    let fft = server_rack_1.find_named("fft").unwrap();
    let a = server_rack_1.find_path(start, fft, 0, Visited::new().mark(dac));
    println!("a: {a}");
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
