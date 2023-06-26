module main

import vweb
import time

__global (
	q Queue
)

struct Queue {
	mut:
	m map[string]chan string
}
fn (mut q Queue) add(q_name string, v string) {
	_ = q.m[q_name] or {
		q.m[q_name] = chan string{cap: 100}
		q.m[q_name] <- v
		return
	}
	q.m[q_name] <- v
}

fn (mut q Queue) pop(q_name string) !string {
	ch := q.m[q_name] or { return NotFoundError{} }
	mut item := ''
	state := ch.try_pop(mut item)
	if state == ChanState.not_ready || state == ChanState.closed {
		return NotFoundError{}
	}
	return item
}

fn (mut q Queue) wait(sec int, q_name string) !string {
	ch := q.m[q_name] or { return NotFoundError{} }
	select {
		item := <-ch {
			return item
		}
		sec * time.second {
			return NotFoundError{}
		}
	}
	return NotFoundError{}
}

struct App {
	vweb.Context
}

struct NotFoundError {
	Error
}

fn main() {
	mut qq := Queue{}
	q = qq
	vweb.run_at(App{}, vweb.RunParams{
		port: 8081
	})!
}

['/:q'; 'put']
pub fn (mut app App) put(qq string) vweb.Result {
	v := app.query['v'] or {
		app.set_status(vweb.http_400.status_code, 'bad request')
		return app.ok('')
	}
	q.add(qq, v)
	return app.ok('')
}

['/:q'; 'get']
pub fn (mut app App) get(qq string) vweb.Result {
	t := app.query['timeout'] or {
		res := q.pop(qq) or { return app.not_found() }
		return app.json(res)
	}.int()
	res := q.wait(t, qq) or { return app.not_found() }
	return app.json(res)
}
