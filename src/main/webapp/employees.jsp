
<%@ page import="java.util.List" %>
<%@ page import="com.employee.model.Employee" %>

<!DOCTYPE html>
<html>
<head>
    <title>Employee List</title>
</head>
<body>

    <h1>Employee Management System</h1>
    <h2>Employee Records</h2>

    <%
        List<Employee> employees =
            (List<Employee>) request.getAttribute("employees");
    %>

    <% if (employees == null || employees.isEmpty()) { %>

        <p>No employee records found.</p>

    <% } else { %>

        <table border="1" cellpadding="10">
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Department</th>
                <th>Salary</th>
            </tr>

            <% for (Employee employee : employees) { %>
                <tr>
                    <td><%= employee.getId() %></td>
                    <td><%= employee.getName() %></td>
                    <td><%= employee.getEmail() %></td>
                    <td><%= employee.getDepartment() %></td>
                    <td><%= employee.getSalary() %></td>
                </tr>
            <% } %>

        </table>

    <% } %>

    <br>
    <a href="index.jsp">Back to Home</a>

</body>
</html>
