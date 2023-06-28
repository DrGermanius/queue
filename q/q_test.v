import q

fn test_add_pop_happy_path() {
	mut q := q.Queue{}
	q.add('test', '1')
	q.add('test', '2')
	mut v := q.pop('test') or { panic('test_add first pop fails') }
	assert v == '1'
	v = q.pop('test') or { panic('test_add second pop fails') }
	assert v == '2'
}
