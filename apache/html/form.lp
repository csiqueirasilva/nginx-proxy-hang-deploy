#!/usr/bin/env cgilua.cgi
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>GET and POST Form Example</title>
</head>
<body>
  <h1>GET and POST Form Example</h1>
  <p>
    This page contains two forms (GET and POST) that submit to the same page. The submitted parameters and request method will be displayed below.
  </p>

  <h2>GET Form</h2>
  <form method="get" action="form.lp">
    <label for="getName">Name:</label>
    <input type="text" id="getName" name="name" placeholder="Enter your name">
    <br>
    <label for="getAge">Age:</label>
    <input type="number" id="getAge" name="age" placeholder="Enter your age">
    <br>
    <input type="submit" value="Submit GET">
  </form>

  <h2>POST Form</h2>
  <form method="post" action="form.lp">
    <label for="postEmail">Email:</label>
    <input type="email" id="postEmail" name="email" placeholder="Enter your email">
    <br>
    <label for="postMessage">Message:</label>
    <textarea id="postMessage" name="message" placeholder="Enter your message"></textarea>
    <br>
    <input type="submit" value="Submit POST">
  </form>

  <h2>Submitted Parameters</h2>
  <pre>
    <%
      -- Determine the request method
      local method = cgilua.servervariable("REQUEST_METHOD")
      cgilua.put("Received " .. method .. " request\n\n")

      -- Function to print parameters
      local function print_params(params)
        for key, value in pairs(params) do
          cgilua.put(key .. ": " .. value .. "\n")
        end
      end

      -- Handle GET and POST parameters
      if method == "GET" then
        print_params(cgilua.QUERY)
      elseif method == "POST" then
        print_params(cgilua.POST)
      end
    %>
  </pre>
</body>
</html>
