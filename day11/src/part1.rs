use std::{collections::HashMap, str::FromStr};

const FILE: &str = include_str!("../input.txt");
pub fn part1() {
    let _server_rack: ServerRack = FILE.parse().unwrap();
    println!("Hello, World!");
}
struct Device {
    name: String,
    connected_to: Vec<String>,
}
impl FromStr for Device {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (name, connections) = s.split_once(": ").ok_or(())?;
        let connections = connections
            .split(' ')
            .map(str::trim)
            .map(str::to_string)
            .collect();
        Ok(Self {
            name: name.to_string(),
            connected_to: connections,
        })
    }
}
#[derive(Debug, PartialEq)]
struct ServerRack {
    components: Vec<Component>,
}
#[derive(Debug, PartialEq)]
enum Component {
    Start(Vec<usize>),
    End,
    Node(Vec<usize>),
}
impl FromStr for ServerRack {
    type Err = ();

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let devices = s
            .trim()
            .lines()
            .map(Device::from_str)
            .collect::<Result<Vec<_>, ()>>()?;
        let binding = vec![Device {
            name: "out".to_string(),
            connected_to: Vec::new(),
        }];
        let devices = binding.iter().chain(devices.iter()).collect::<Vec<_>>();
        let indices = devices
            .iter()
            .enumerate()
            .map(|(i, d)| (&d.name, i))
            .collect::<HashMap<_, _>>();
        let components = devices
            .into_iter()
            .map(|d| {
                let connections = d
                    .connected_to
                    .iter()
                    .map(|name| indices.get(name).copied())
                    .collect::<Option<Vec<_>>>()
                    .ok_or(())?;
                Ok(match d.name.as_str() {
                    "out" => Component::End,
                    "you" => Component::Start(connections),
                    _ => Component::Node(connections),
                })
            })
            .collect::<Result<Vec<_>, ()>>()?;
        Ok(Self { components })
    }
}

#[test]
fn test_parsing() {
    let server_rack: ServerRack = FILE.parse().unwrap();
    let expected: ServerRack = ServerRack { components: vec![
        Component::End,
        Component::Node(vec![2, 9]), // aaa
        Component::Start(vec![3, 4]), // you
        Component::Node(vec![5, 6]), // bbb
        Component::Node(vec![5, 6, 7]), // ccc
        Component::Node(vec![8]), // ddd
        Component::Node(vec![0]), // eee
        Component::Node(vec![0]), // fff
        Component::Node(vec![0]), // ggg
        Component::Node(vec![4, 7, 10]), // hhh
        Component::Node(vec![0]), // iii
    ] };
    assert_eq!(server_rack, expected);
}
