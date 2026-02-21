use std::{collections::HashMap, str::FromStr};

pub const FILE: &str = include_str!("../input.txt");

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
pub struct ServerRack {
    components: Vec<Component>,
    component_name_to_id: HashMap<String, usize>,
    component_id_to_name: Vec<String>,
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
        let component_name_to_id = devices
            .iter()
            .enumerate()
            .map(|(i, d)| (d.name.clone(), i))
            .collect();
        let component_id_to_name = devices.iter().map(|d| d.name.clone()).collect();
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
        Ok(Self {
            components,
            component_name_to_id,
            component_id_to_name,
        })
    }
}

impl ServerRack {
    pub fn find_path(&self, current: usize, end: usize, depth: usize) -> u32 {
        if current == end {
            return 1;
        }
        if depth >= self.components.len() {
            return 0;
        }
        match self.components[current] {
            Component::End => unreachable!("This can only happen with more than one end node, since start == end, or not searching for end"),
            Component::Start(ref connections) | Component::Node(ref connections) => connections.iter().map(|&start|Self::find_path(self, start, end, depth+1)).sum()
        }
    }
    // This does not work like expected
    #[allow(unused)]
    pub fn find_path_with_requirements(
        &self,
        start: usize,
        req_1: usize,
        req_1_found: bool,
        req_2: usize,
        req_2_found: bool,
        end: usize,
        depth: usize,
    ) -> u32 {
        if start == end {
            return if req_1_found && req_2_found { dbg!(1) } else { 0 };
        }
        if depth >= self.components.len() {
            return 0;
        }
        match self.components[start] {
            Component::End => unreachable!("This can only happen with more than one end node, since start == end, or not searching for end"),
            Component::Start(ref connections) | Component::Node(ref connections) => connections.iter().map(|&current|
                Self::find_path_with_requirements(self, current, req_1, req_1_found || current == req_1, req_2, req_2_found || current == req_2, end, depth+1)
            ).sum()
        }
    }
    #[allow(unused)]
    pub fn find_named(&self, name: &str) -> Option<usize> {
        self.component_name_to_id.get(name).copied()
    }
    pub fn find_start(&self) -> usize {
        self.components
            .iter()
            .enumerate()
            .find(|(_, c)| matches!(c, Component::Start(_)))
            .map(|(i, _)| i)
            .expect("There should always be a start")
    }
}

#[test]
fn test_parsing() {
    let server_rack = FILE.parse::<ServerRack>().unwrap().components;
    let expected = vec![
        Component::End,
        Component::Node(vec![2, 9]),     // aaa
        Component::Start(vec![3, 4]),    // you
        Component::Node(vec![5, 6]),     // bbb
        Component::Node(vec![5, 6, 7]),  // ccc
        Component::Node(vec![8]),        // ddd
        Component::Node(vec![0]),        // eee
        Component::Node(vec![0]),        // fff
        Component::Node(vec![0]),        // ggg
        Component::Node(vec![4, 7, 10]), // hhh
        Component::Node(vec![0]),        // iii
    ];
    assert_eq!(server_rack, expected);
}
#[test]
fn test_path_traversal() {
    let server_rack = ServerRack {
        components: vec![
            Component::End,
            Component::Start(vec![2, 3]),
            Component::Node(vec![0]),
            Component::Node(vec![0]),
        ],
        component_id_to_name: Vec::new(),     // Dummy
        component_name_to_id: HashMap::new(), // Dummy
    };
    assert_eq!(server_rack.find_path(1, 0, 0), 2);
}
#[test]
fn test_find_start() {
    let server_rack = ServerRack {
        components: vec![
            Component::End,
            Component::Start(vec![2, 3]),
            Component::Node(vec![0]),
            Component::Node(vec![0]),
        ],
        component_id_to_name: Vec::new(),     // Dummy
        component_name_to_id: HashMap::new(), // Dummy
    };
    assert_eq!(server_rack.find_start(), 1);
}
