package com.boatsafari.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestJdbc {
    public static void main(String[] args) {
        String[] urls = {
            "jdbc:sqlserver://localhost:1433;databaseName=boat_safari_db;user=boat_safari_user;password=BoatSafari@2026;encrypt=true;trustServerCertificate=true;",
            "jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=boat_safari_db;user=boat_safari_user;password=BoatSafari@2026;encrypt=true;trustServerCertificate=true;",
            "jdbc:sqlserver://127.0.0.1:1433;databaseName=boat_safari_db;user=boat_safari_user;password=BoatSafari@2026;encrypt=true;trustServerCertificate=true;"
        };

        for (String url : urls) {
            System.out.println("\n--- Testing URL: " + url + " ---");
            try {
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                try (Connection conn = DriverManager.getConnection(url)) {
                    System.out.println("SUCCESS! Connected to SQL Server!");
                    try (Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM information_schema.tables")) {
                        if (rs.next()) {
                            System.out.println("Total tables in SQL Server: " + rs.getInt(1));
                        }
                    }
                }
            } catch (Exception e) {
                System.out.println("FAILED: " + e.getClass().getName() + ": " + e.getMessage());
                e.printStackTrace(System.out);
            }
        }
    }
}
