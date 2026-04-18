use crate::utils::{ServerRack, Visited, FILE};

pub fn part2() {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let start = server_rack.find_named("svr").unwrap();
    let fft = server_rack.find_named("fft").unwrap();
    let dac = server_rack.find_named("dac").unwrap();
    let end = server_rack.find_named("out").unwrap();
    let fft_dac = explore(&server_rack, start, fft, dac, end);
    let dac_fft = explore(&server_rack, start, dac, fft, end);
    println!("{}", fft_dac + dac_fft);
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
    let nodes = server_rack.nodes_on_path(start, end, ignore);
    let server_rack_1 = server_rack.clone().filter(nodes);
    let amount = server_rack_1.find_path(start, end, 0, Visited::new());
    println!("amount: {amount}, start {start} end {end} ignore {ignore}");
    amount
}
