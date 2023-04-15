use std::env;
use std::fs::File;
use std::io::{self, BufReader};
use ripemd::{Ripemd320, Digest};

fn main() {
	let args: Vec<String> = env::args().collect();

	if args.len() > 1 {
		for filename in &args[1..] {
			let mut hasher = Ripemd320::new();
			match File::open(&filename) {
				Ok(file) => {
					let mut reader = BufReader::new(file);
					let _ = io::copy(&mut reader, &mut hasher);
					let hash = hasher.finalize();
					println!("RIPEMD320 ({}) = {:x}", filename, hash);
				}
				Err(e) => {
					eprintln!("Error opening file {}: {}", filename, e);
					continue;
				}
			}
		}
	} else {
		let mut stdin = io::stdin();
		let mut hasher = Ripemd320::new();
		let _ = io::copy(&mut stdin, &mut hasher);
		let hash = hasher.finalize();
		println!("{:x}", hash);
	}
}
