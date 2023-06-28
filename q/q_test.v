import q

fn test_add_pop_happy_path() {
	mut qq := q.Queue{}
	qq.add('test', '1')
	qq.add('test', '2')
	mut v := qq.pop('test') or { panic('test_add first pop fails') }
	assert v == '1'
	v = qq.pop('test') or { panic('test_add second pop fails') }
	assert v == '2'
}
