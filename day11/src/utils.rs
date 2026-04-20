use std::{
    collections::{HashMap, HashSet, VecDeque},
    str::FromStr,
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
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
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

