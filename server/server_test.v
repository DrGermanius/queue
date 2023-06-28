import queue
import net.http
import server
import sync

fn test_server() {
	q := q.Queue{}
	f := fn (q q.Queue) {
		server.run_server(q) or { panic(err) }
	}
	spawn f(q)

	// putting values
	mut res := http.put('http://localhost:8081/test?v=1', '') or { panic(err) }
	assert res.status_code == 200

	res = http.put('http://localhost:8081/test?v=2', '') or { panic(err) }
	assert res.status_code == 200

	res = http.put('http://localhost:8081/another?v=2', '') or { panic(err) }
	assert res.status_code == 200

	// getting values
	res = http.get('http://localhost:8081/test') or { panic(err) }
	assert res.status_code == 200
	assert res.body.contains('1')
	assert !res.body.contains('2')

	res = http.get('http://localhost:8081/test') or { panic(err) }
	assert res.status_code == 200
	assert res.body.contains('2')
	assert !res.body.contains('1')

	res = http.get('http://localhost:8081/another') or { panic(err) }
	assert res.status_code == 200
	assert res.body.contains('2')
	assert !res.body.contains('1')

	// queue is empty
	res = http.get('http://localhost:8081/another') or { panic(err) }
	assert res.status_code == 404

	res = http.get('http://localhost:8081/test') or { panic(err) }
	assert res.status_code == 404

	// no v arg provided
	res = http.put('http://localhost:8081/test', '') or { panic(err) }
	assert res.status_code == 400

	// timeout test
	mut wg := sync.new_waitgroup()
	// wg.add(2)
	// spawn fn [mut wg] () {
	// 	r := http.get('http://localhost:8081/test?timeout=10') or { panic(err) }
	// 	assert r.status_code == 200
	// 	assert r.body.contains('1')
	// 	wg.done()
	// }()
	// // make sure that previous thread started
	// time.sleep(1 * time.second)

	// spawn fn [mut wg] () {
	// 	r := http.get('http://localhost:8081/test?timeout=10') or { panic(err) }
	// 	assert r.status_code == 200
	// 	assert r.body.contains('2')
	// 	wg.done()
	// }()

	// res = http.put('http://localhost:8081/test?v=1', '') or { panic(err) }
	// assert res.status_code == 200
	//
	// // res = http.put('http://localhost:8081/test?v=2', '') or { panic(err) }
	// // assert res.status_code == 200
	//
	// wg.wait()
	//
	// if nothing written to queue
	wg.add(1)
	spawn fn [mut wg] () {
		r := http.get('http://localhost:8081/test?timeout=2') or { panic(err) }
		assert r.status_code == 404
		wg.done()
	}()
	wg.wait()
	//
	// if something has already written to queue
	res = http.put('http://localhost:8081/test?v=1', '') or { panic(err) }
	assert res.status_code == 200

	wg.add(1)
	spawn fn [mut wg] () {
		r := http.get('http://localhost:8081/test?timeout=2') or { panic(err) }
		assert r.status_code == 200
		assert r.body.contains('1')
		wg.done()
	}()
	wg.wait()
}
