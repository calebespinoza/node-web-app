const app = require('./server')
const supertest = require('supertest')
const request = supertest(app)

describe("GET /", () => {
    test("Get the test endpoint", async () => {
        const response = await request.get('/')
        expect(response.status).toBe(200)
        expect(response.body.message).toBe('Hello World')
    })
})

describe("GET /atlatam01", () => {
    test("Get the test endpoint", async () => {
        const response = await request.get('/atlatam01')
        expect(response.status).toBe(200)
        expect(response.body.message).toBe('Hello Bootcampers!!')
    })
})