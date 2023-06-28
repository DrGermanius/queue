module server

import vweb
import q

__global (
	q q.Queue
)

struct App {
	vweb.Context
}

pub fn run_server(qq q.Queue) ! {
	q = qq
	return vweb.run_at(App{}, vweb.RunParams{
		port: 8081
	})
}

['/:queue'; 'put']
pub fn (mut app App) put(qq string) vweb.Result {
	v := app.query['v'] or {
		app.set_status(vweb.http_400.status_code, 'bad request')
		return app.ok('')
	}
	q.add(qq, v)
	return app.ok('')
}

['/:queue'; 'get']
pub fn (mut app App) get(qq string) vweb.Result {
	t := app.query['timeout'] or {
		res := q.pop(qq) or { return app.not_found() }
		return app.json(res)
	}.int()
	res := q.wait(t, qq) or { return app.not_found() }
	return app.json(res)
}
