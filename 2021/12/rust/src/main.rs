use std::fs;
use std::collections::HashMap;
use std::collections::HashSet;

type CaveIndex = usize;

// aka "graph node"
#[derive(Clone, Debug)]
struct Cave {
   name: String,
   from_list: Vec<CaveIndex>,
   to_list: Vec<CaveIndex>,
}

#[derive(Clone, Debug)]
struct CaveGraph {
   name_map: HashMap<String, CaveIndex>,
   list: Vec<Cave>,
}

fn graph_ensure_cave_exists(graph: &mut CaveGraph, name: &String) {
   if !graph.name_map.contains_key(name) {
      let cave = Cave {
         name: name.clone(),
         from_list: vec![],
         to_list: vec![],
      };

      // insert
      let index = graph.list.len();
      graph.name_map.insert(cave.name.clone(), index);
      graph.list.push(cave);
   }
}

fn graph_link_caves_forward(graph: &mut CaveGraph, from_name: &String, to_name: &String) {
   assert!(graph.name_map.contains_key(from_name));
   assert!(graph.name_map.contains_key(to_name));

   let from_index = graph.name_map.get(from_name).unwrap();
   let from_cave = graph.list.get_mut(*from_index).unwrap();
   let to_index = graph.name_map.get(to_name).unwrap();
   from_cave.to_list.push(*to_index);
}

fn graph_link_caves_backward(graph: &mut CaveGraph, from_name: &String, to_name: &String) {
   assert!(graph.name_map.contains_key(from_name));
   assert!(graph.name_map.contains_key(to_name));

   let to_index = graph.name_map.get(to_name).unwrap();
   let to_cave = graph.list.get_mut(*to_index).unwrap();
   let from_index = graph.name_map.get(from_name).unwrap();
   to_cave.from_list.push(*from_index);
}

#[inline(always)]
fn graph_link_caves_bidirectional(graph: &mut CaveGraph, from_name: &String, to_name: &String) {
   graph_link_caves_forward(graph, from_name, to_name);
   graph_link_caves_backward(graph, from_name, to_name);
}

fn parse_contents_to_cave_graph(contents: String) -> CaveGraph {
   let mut cave_graph = CaveGraph {
      name_map: HashMap::<String, CaveIndex>::new(),
      list: Vec::<Cave>::new(),
   };

   for line in contents.lines() {
      let (from, to) = line.split_once("-").unwrap();
      let from_string = String::from(from);
      let to_string = String::from(to);

      graph_ensure_cave_exists(&mut cave_graph, &from_string);
      graph_ensure_cave_exists(&mut cave_graph, &to_string);
      graph_link_caves_bidirectional(&mut cave_graph, &from_string, &to_string);
   }

   return cave_graph;
}

fn graph_get_cave_by_index<'a>(graph: &'a CaveGraph, index: CaveIndex) -> Option<&'a Cave> {
   match graph.list.get(index) {
      Some(cave) => Some(cave),
      _ => None,
   }
}

fn cave_is_big(name: &String) -> bool {
   assert!(name.len() > 0);
   let first_char = name.chars().nth(0).unwrap();
   return first_char >= 'A' && first_char <= 'Z';
}

fn visit_cave2(graph: &CaveGraph, index: CaveIndex, visited_set: HashSet<CaveIndex>, allow_revisit: bool) -> i32 {
   let cave = graph_get_cave_by_index(graph, index).unwrap();
   if cave.name == "end" { return 1; }

   let mut path_count = 0;
   for to_index in cave.to_list.iter().chain(cave.from_list.iter()) {
      let to_cave = graph_get_cave_by_index(graph, *to_index).unwrap();
      if to_cave.name == "start" { continue; }

      if cave_is_big(&to_cave.name) || !visited_set.contains(to_index) || allow_revisit {
         let mut new_visited_set = visited_set.clone();
         new_visited_set.insert(*to_index);
         // if we've used our allow revisit, don't allow any more revisits
         let new_allow_revisit = allow_revisit && (cave_is_big(&to_cave.name) || !visited_set.contains(to_index));
         path_count += visit_cave2(graph, *to_index, new_visited_set.clone(), new_allow_revisit);
      }
   }

   return path_count;
}

fn part1(cave_graph: CaveGraph) {
   let start_index = *cave_graph.name_map.get("start").unwrap();
   let visited_set = HashSet::<CaveIndex>::new();
   let path_count = visit_cave2(&cave_graph, start_index, visited_set, false);

   println!("PART1: {}", path_count);
}

fn part2(cave_graph: CaveGraph) {
   // Much like part1, except for every small cave we visit we branch
   // for whether it will be allowed to visit only once or twice.
   let start_index = *cave_graph.name_map.get("start").unwrap();
   let visited_set = HashSet::<CaveIndex>::new();
   let path_count = visit_cave2(&cave_graph, start_index, visited_set, true);

   println!("PART2: {}", path_count);
}

fn main() {
   let filename = "../input.txt";
   // let filename = "../test1.txt";
   let contents = fs::read_to_string(filename)
      .expect("Failed to read the file");

   // We construct a directed graph, but it could be simplified to
   // an undirected graph to solve the problem statement.
   let cave_graph = parse_contents_to_cave_graph(contents);
   assert!(cave_graph.name_map.contains_key("start"));
   assert!(cave_graph.name_map.contains_key("end"));

   // for cave in &cave_graph.list {
   //    println!("{:?}", cave);
   // }

   part1(cave_graph.clone());
   part2(cave_graph);
}
