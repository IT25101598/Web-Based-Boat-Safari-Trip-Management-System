package com.boatsafari.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        String[] urls = {
            "jdbc:sqlserver://localhost\\SQLEXPRESS;databaseName=boat_safari_db;integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
            "jdbc:sqlserver://localhost:1433;databaseName=boat_safari_db;integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
            "jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=boat_safari_db;integratedSecurity=true;encrypt=true;trustServerCertificate=true;",
            "jdbc:jtds:sqlserver://localhost/boat_safari_db;instance=SQLEXPRESS;useNTLMv2=true;domain=LAPTOP-B194ES3A",
            "jdbc:jtds:sqlserver://localhost/boat_safari_db;instance=SQLEXPRESS"
        };

        for (String url : urls) {
            System.out.println("Trying: " + url);
            try {
                if (url.contains("jtds")) {
                    Class.forName("net.sourceforge.jtds.jdbc.Driver");
                } else {
                    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                }
                try (Connection conn = DriverManager.getConnection(url);
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM dbo.vessels")) {
                    if (rs.next()) {
                        System.out.println("SUCCESS! Count = " + rs.getInt(1) + " with " + url);
                        return;
                    }
                }
            } catch (Throwable e) {
                System.out.println("FAILED: " + e.getMessage());
            }
        }
    }
}
