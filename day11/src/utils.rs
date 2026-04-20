use std::{
    collections::{HashMap, HashSet},
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

