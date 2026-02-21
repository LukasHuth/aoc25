use crate::utils::{ServerRack, FILE};

pub fn part1() {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let start = server_rack.find_start();
    let result = server_rack.find_path(start, 0, 0);
    println!("{result}");
}
