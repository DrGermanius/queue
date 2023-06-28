module server

import vweb
import queue

__global (
	q queue.Queue
)

struct App {
	vweb.Context
}

pub fn run_server(qq queue.Queue) ! {
	q = qq
	return vweb.run_at(App{}, vweb.RunParams{
		port: 8081
	})
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
