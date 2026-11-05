
package com.employee.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException {
    String url = System.getenv("DB_URL");
    String username = System.getenv("DB_USERNAME");
    String password = System.getenv("DB_PASSWORD");

    if (url == null || username == null || password == null) {
        throw new SQLException(
            "Database environment variables are not configured."
        );
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        throw new SQLException("MySQL JDBC driver not found.", e);
    }

    return DriverManager.getConnection(url, username, password);
}
