# Queue Broker Web Service

This project is a web service that implements a queue broker. The service handles two methods: `PUT` and `GET`.

## PUT Method

To put a message into a queue, use the following endpoint:

```
PUT /queue?v=message
```

- Replace `queue` with the name of the desired queue (any name can be used).
- Replace `message` with the content of the message.

Example usage:

```bash
curl -XPUT http://127.0.0.1/queue?v=cat
curl -XPUT http://127.0.0.1/queue?v=dog
curl -XPUT http://127.0.0.1/queue?v=manager
curl -XPUT http://127.0.0.1/queue?v=executive
```

The response will be an empty body with status code 200 (OK). If the `v` parameter is missing, the response will be an empty body with status code 400 (Bad Request).

## GET Method

To retrieve a message from a queue based on the FIFO (First-In, First-Out) principle, use the following endpoint:

```
GET /queue
```

Example usage:

```bash
curl http://127.0.0.1/queue => cat
curl http://127.0.0.1/queue => dog
curl http://127.0.0.1/queue => manager
curl http://127.0.0.1/queue => executive
```

If there are no messages in the queue, the response will be an empty body with status code 404 (Not Found).

### Timeout Argument

For `GET` requests, you can specify a timeout argument using the following format:

```
GET /queue?timeout=N
```

Replace `N` with the desired timeout value in seconds. If there are no ready messages in the queue, the recipient will wait either until a message arrives or until the timeout expires. If the timeout is reached and no message appears, the response will be a status code 404 (Not Found).

Note: Recipients receive messages in the same order as their requests were made. If multiple recipients are waiting for a message using the timeout, the first recipient to make the request will receive the first message.
