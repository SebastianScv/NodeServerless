require('dotenv').config({path: '.env'})
jest.setTimeout(9999);

const handler = require('../src/handler');

test('Check hello-world endpoint', async () => {
    const response = await handler.hello();
    expect(response.statusCode).toBe(200);
});
