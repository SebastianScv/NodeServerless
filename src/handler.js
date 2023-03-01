const pg = require("pg");

module.exports.hello = async (event) => {
  const dbClient = new pg.Client({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
  });
  await dbClient.connect();
  const { rows } = await dbClient.query("SELECT NOW()");

  return {
    statusCode: 200,
    body: JSON.stringify({
      rows,
      message: "Hello world!",
    }),
  };
};

module.exports.report = async (event) => {
  const id = event.pathParameters && parseInt(event.pathParameters.id);
  if (!id) {
    return {
      statusCode: 400,
      body: "Missing required parameter 'id'",
    };
  }

  const dbClient = new pg.Client({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
  });

  try {
    await dbClient.connect();

    const query = `
      SELECT event_user, event_time, event_type, table_name, record_old, record_new
      FROM test_hst.audit
      WHERE object_id = $1
      ORDER BY event_time DESC
    `;

    const { rows } = await dbClient.query(query, [id]);
    if (rows.length === 0) {
      return {
        statusCode: 404,
        body: JSON.stringify({
          message: `Audit records not found for id ${id}`,
        }),
      };
    }

    const results = rows.map((row) => {
      const {
        event_user,
        event_time,
        event_type,
        table_name,
        record_old,
        record_new,
      } = row;
      const changes = [];

      if (record_old && !record_new) {
        changes.push(`Record deleted by ${event_user} at ${event_time}`);
      } else if (record_new && !record_old) {
        changes.push(`Record inserted by ${event_user} at ${event_time}`);
      } else {
        for (const key in record_new) {
          const oldValue = record_old[key];
          const newValue = record_new[key];

          if (oldValue !== newValue) {
            changes.push(
              `${key} changed from "${oldValue}" to "${newValue}" by ${event_user} at ${event_time}`
            );
          }
        }
      }

      return {
        event_user,
        event_time,
        event_type,
        table_name,
        changes,
      };
    });

    const html = `
      <html>
        <head>
          <style>
            table {
              border-collapse: collapse;
              width: 100%;
            }
            th, td {
              border: 1px solid black;
              padding: 8px;
              text-align: left;
            }
            th {
              background-color: #f2f2f2;
            }
          </style>
        </head>
        <body>
          <h1>Audit records for id ${id}</h1>
          <table>
            <thead>
              <tr>
                <th>Event User</th>
                <th>Event Time</th>
                <th>Event Type</th>
                <th>Table Name</th>
                <th>Changes</th>
              </tr>
            </thead>
            <tbody>
              ${results
                .map(
                  (result) => `
                <tr>
                  <td>${result.event_user}</td>
                  <td>${result.event_time}</td>
                  <td>${result.event_type}</td>
                  <td>${result.table_name}</td>
                  <td>${result.changes.join("<br>")}</td>
                </tr>
              `
                )
                .join("")}
            </tbody>
          </table>
        </body>
      </html>
    `;

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "text/html",
      },
      body: html,
    };
  } catch (error) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Internal server error",
      }),
    };
  } finally {
    await dbClient.end();
  }
};
