use std::collections::VecDeque;

use crate::utils::{Component, ServerRack, FILE};

pub fn part2() {
    let result = part2_int();
    println!("{result}");
}

fn part2_int() -> u64 {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let start = server_rack.find_named("svr").unwrap();
    let fft = server_rack.find_named("fft").unwrap();
    let dac = server_rack.find_named("dac").unwrap();
    let end = server_rack.find_named("out").unwrap();
    /*
    let fft_dac = explore(&server_rack, start, fft, dac, end);
    let dac_fft = explore(&server_rack, start, dac, fft, end);
    println!("{}", fft_dac + dac_fft);
    */
    let neigbours = server_rack
        .components
        .iter()
        .map(|c| match c {
            Component::End => vec![],
            Component::Start(c) | Component::Node(c) => c.clone(),
        })
        .collect();
    let topo = topo_sort(server_rack.components.len(), &neigbours);
    let start_fft = count_possible_ways(start, fft, &topo, &neigbours);
    let fft_dac = count_possible_ways(fft, dac, &topo, &neigbours);
    let dac_end = count_possible_ways(dac, end, &topo, &neigbours);
    let result = start_fft * fft_dac * dac_end;
    result
}
#[test]
fn test_part2() {
    assert_eq!(part2_int(), 349322478796032);
}

pub fn topo_sort(n: usize, edges: &Vec<Vec<usize>>) -> Vec<usize> {
    let mut in_degree = vec![0; n];
    for u in 0..n {
        for &v in &edges[u] {
            in_degree[v] += 1;
        }
    }

    let mut queue = VecDeque::new();

    for i in 0..n {
        if in_degree[i] == 0 {
            queue.push_back(i);
        }
    }

    let mut topo = Vec::new();

    while let Some(u) = queue.pop_front() {
        topo.push(u);

        for &v in &edges[u] {
            in_degree[v] -= 1;
            if in_degree[v] == 0 {
                queue.push_back(v);
            }
        }
    }

    topo
}

pub fn count_possible_ways(
    start: usize,
    end: usize,
    topo: &Vec<usize>,
    neigbours: &Vec<Vec<usize>>,
) -> u64 {
    let mut dp: Vec<u64> = vec![0; topo.len()];
    dp[start] = 1;
    for &node in topo {
        for &next in &neigbours[node] {
            dp[next] += dp[node];
        }
    }
    dp[end]
}
