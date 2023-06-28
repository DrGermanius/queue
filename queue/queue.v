module queue

import time

pub struct Queue {
mut:
	m map[string][]chan string
}

struct NotFoundError {
	Error
}

pub fn (mut q Queue) add(q_name string, v string) {
	_ = q.m[q_name] or {
		ch := chan string{cap: 100}
		ch <- v
		q.m[q_name] << ch
		return
	}
	if q.m[q_name].len > 1 {
		q.m[q_name][1] <- v
		return
	}
	q.m[q_name][0] <- v
}

pub fn (mut q Queue) pop(q_name string) !string {
	chlist := q.m[q_name] or { return NotFoundError{} }
	mut item := ''
	state := chlist.first().try_pop(mut item)
	if state == ChanState.not_ready || state == ChanState.closed {
		return NotFoundError{}
	}
	return item
}

pub fn (mut q Queue) wait(sec int, q_name string) !string {
	_ := q.m[q_name] or { return NotFoundError{} }
	ch := chan string{}
	q.m[q_name] << ch
	defer {
		q.m[q_name].delete(q.m[q_name].index(ch))
	}
	mut item := ''
	select {
		item = <-q.m[q_name][0] {
			return item
		}
		item = <-ch {
			return item
		}
		sec * time.second {
			return NotFoundError{}
		}
	}
	return NotFoundError{}
}
