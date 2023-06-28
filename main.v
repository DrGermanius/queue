module main

import server
import q

fn main() {
	server.run_server( q.Queue{})!
}
