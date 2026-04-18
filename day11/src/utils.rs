use std::{
    collections::{HashMap, HashSet},
    str::FromStr,
    vec::IntoIter,
};

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
#[derive(Debug, PartialEq, Clone)]
pub struct ServerRack {
    pub components: Vec<Component>,
    pub component_name_to_id: HashMap<String, usize>,
    pub component_id_to_name: Vec<String>,
    pub allowed_components: HashSet<usize>,
}
#[derive(Debug, PartialEq, Clone)]
pub enum Component {
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
            allowed_components: (0..components.len()).collect(),
            components,
            component_name_to_id,
            component_id_to_name,
        })
    }
}

const VISITED_AMOUNT: usize = 1024;
const VISITED_SIZE: usize = VISITED_AMOUNT / 64;
#[derive(Debug, Clone, Copy)]
pub struct Visited {
    data: [u64; VISITED_SIZE],
}
pub struct VisitedIter<'a> {
    data: &'a [u64; VISITED_SIZE],
    current: usize,
}
#[test]
fn test_visited_iter() {
    let visited = Visited::new();
    let iter = visited.iter();
    assert_eq!(iter.collect::<Vec<usize>>(), vec![]);
    let visited = Visited::new().mark(12);
    println!("{visited:?}");
    let iter = visited.iter();
    assert_eq!(iter.collect::<Vec<usize>>(), vec![12]);
}
impl<'a> Iterator for VisitedIter<'a> {
    type Item = usize;

    fn next(&mut self) -> Option<Self::Item> {
        while self
            .data
            .get(self.current / 64)
            .is_some_and(|v| (v >> (self.current & 63)) & 1 == 0)
        {
            self.current += 1;
        }
        if self.data.len() <= self.current / 64 {
            None
        } else {
            self.current += 1;
            Some(self.current - 1)
        }
    }
}
impl std::fmt::Display for Visited {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        for i in 0..VISITED_SIZE {
            for offset in 0..64 {
                f.write_fmt(format_args!("{}: ", i * 64 + offset))?;
                if (self.data[i] & 1) << offset != 0 {
                    f.write_str("Visited")?;
                } else {
                    f.write_str("Not Visited")?;
                }
                f.write_str("\n")?;
            }
        }
        Ok(())
    }
}
impl Visited {
    pub fn new() -> Self {
        Self {
            data: [0; VISITED_SIZE],
        }
    }
    pub fn mark(&self, pos: usize) -> Self {
        let index = pos / 64;
        let offset = pos & 63;
        let mut data = self.data;
        data[index] |= 1 << offset;
        Self { data }
    }
    pub fn unmark(&self, pos: usize) -> Self {
        let index = pos / 64;
        let offset = pos & 63;
        let mut data = self.data;
        data[index] &= !(1 << offset);
        Self { data }
    }
    pub fn is_visited(&self, pos: usize) -> bool {
        let index = pos / 64;
        let offset = pos & 63;
        (self.data[index] & 1 << offset) != 0
    }
    pub fn iter<'a>(&'a self) -> VisitedIter<'a> {
        VisitedIter {
            data: &self.data,
            current: 0,
        }
    }
}
impl ServerRack {
    pub fn explore(
        &self,
        current: usize,
        end: usize,
        mut visited: Visited,
        cache: &mut HashMap<usize, (bool, Visited)>,
    ) -> (bool, Visited) {
        if let Some(value) = cache.get(&current) {
            return *value;
        }
        if end == current {
            return (true, visited.mark(current));
        }
        if visited.is_visited(current) {
            return (false, visited);
        }
        visited = visited.mark(current);
        match self.components[current] {
            Component::End => (false, visited),
            Component::Start(ref connections) | Component::Node(ref connections) => {
                let mut f = false;
                for &connection in connections {
                    let (found, new_visited) = self.explore(connection, end, visited, cache);
                    if found {
                        visited = new_visited;
                        f = found;
                    }
                }
                let v = if f {
                    (f, visited)
                } else {
                    (false, visited.unmark(current))
                };
                cache.insert(current, v);
                v
            }
        }
    }
    pub fn find_path(
        &self,
        current: usize,
        end: usize,
        depth: usize,
        visited: Visited,
        cache: &mut HashMap<usize, u32>,
    ) -> u32 {
        if let Some(value) = cache.get(&current) {
            return *value;
        }
        if current == end {
            return 1;
        }
        if visited.is_visited(current) || !self.allowed_components.contains(&current) {
            return 0;
        }
        match self.components[current] {
            Component::End => 0,
            Component::Start(ref connections) | Component::Node(ref connections) => {
                let v = connections
                    .iter()
                    .map(|&start| {
                        Self::find_path(self, start, end, depth + 1, visited.mark(current), cache)
                    })
                    .sum();
                cache.insert(current, v);
                if v > 1_000_000 {
                    println!(
                        "v > 1_000_000: {v} depth: {depth} max_depth: {}",
                        self.components.len()
                    );
                }
                v
            }
        }
    }
    // This does not work like expected
    /*
    #[allow(unused)]
    pub fn find_path_with_requirements(
        &self,
        start: usize,
        denied: usize,
        end: usize,
        depth: usize,
    ) -> u32 {
        if start == end {
            return 0;
        }
        if depth >= self.components.len() {
            return 0;
        }
        match self.components[start] {
            Component::End => unreachable!("This can only happen with more than one end node, since start == end, or not searching for end"),
            Component::Start(ref connections) | Component::Node(ref connections) => connections.iter().map(|&current|
                if current == req_1 {
                    // self.find_path(current, end, depth + 1)
                    0
                } else {
                    Self::find_path_with_requirements(self, current, req_1, req_2, one_found || current == req_1 || current == req_2, end, depth+1)
                }
            ).sum()
        }
    }
    */
    #[allow(unused)]
    pub fn find_named(&self, name: &str) -> Option<usize> {
        self.component_name_to_id.get(name).copied()
    }
    pub fn get_component(&self, i: usize) -> Option<&Component> {
        self.components.get(i)
    }
    pub fn find_start(&self) -> usize {
        self.components
            .iter()
            .enumerate()
            .find(|(_, c)| matches!(c, Component::Start(_)))
            .map(|(i, _)| i)
            .expect("There should always be a start")
    }

    pub(crate) fn filter(mut self, allowed_components: HashSet<usize>) -> Self {
        self.allowed_components = self
            .allowed_components
            .iter()
            .filter(|i| allowed_components.contains(i))
            .copied()
            .collect();
        self
    }

    pub(crate) fn allow(&mut self, start: usize) {
        self.allowed_components.insert(start);
    }
}

#[should_panic]
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
        allowed_components: vec![0, 1, 2, 3].into_iter().collect(),
    };
    assert_eq!(server_rack.find_path(1, 0, 0, Visited::new()), 2);
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
        allowed_components: vec![0, 1, 2, 3].into_iter().collect(),
    };
    assert_eq!(server_rack.find_start(), 1);
}
