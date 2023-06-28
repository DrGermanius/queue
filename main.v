module main

import server
import queue

fn main() {
	mut q := queue.Queue{}
	server.run_server(q)!
}
