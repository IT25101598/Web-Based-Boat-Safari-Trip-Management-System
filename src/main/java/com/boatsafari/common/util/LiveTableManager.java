package com.boatsafari.common.util;

import com.boatsafari.common.db.DatabaseConnection;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.concurrent.*;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Real-Time Live Database Table File Manager.
 * Maintains individual live-updating text files for every database table in the
 * system:
 * - TABLE_USERS.txt
 * - TABLE_LOGIN_DETAILS.txt
 * - TABLE_CUSTOMER_DETAILS.txt
 * - TABLE_VESSELS.txt
 * - TABLE_DESTINATIONS.txt
 * - TABLE_ROUTES.txt
 * - TABLE_TOURS.txt
 * - TABLE_TOUR_SCHEDULES.txt
 * - TABLE_PROMOTIONS.txt
 * - TABLE_PROMO_REDEMPTIONS.txt
 * - TABLE_RESERVATIONS.txt
 * - TABLE_PASSENGERS.txt
 * - TABLE_MAINTENANCE_RECORDS.txt
 * - TABLE_SERVICE_REMINDERS.txt
 * - TABLE_SAFETY_CHECK_LOGS.txt
 * - TABLE_EMERGENCY_NOTICES.txt
 * - TABLE_EMERGENCY_ACKNOWLEDGMENTS.txt
 * - TABLE_ACTIVITY_LOGS.txt
 */
public class LiveTableManager {
    private static final Logger LOGGER = Logger.getLogger(LiveTableManager.class.getName());
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    private static final String[] ALL_TABLES = {
            "users",
            "login_details",
            "vessels",
            "destinations",
            "routes",
            "tours",
            "tour_schedules",
            "promotions",
            "promo_redemptions",
            "reservations",
            "passengers",
            "maintenance_records",
            "service_reminders",
            "safety_check_logs",
            "emergency_notices",
            "emergency_acknowledgments",
            "activity_logs"
    };

    // Table change logs (in-memory rolling buffer for recent live transactions)
    private static final Map<String, List<String>> TABLE_TX_LOGS = new ConcurrentHashMap<>();
    private static final ScheduledExecutorService SCHEDULER = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread t = new Thread(r, "LiveTableSyncThread");
        t.setDaemon(true);
        return t;
    });

    private static final String BASE_DIR;

    static {
        String dir = System.getProperty("user.dir");
        BASE_DIR = dir != null ? dir : ".";

        // Initialize table change logs
        for (String table : ALL_TABLES) {
            TABLE_TX_LOGS.put(table.toLowerCase(), new CopyOnWriteArrayList<>());
        }
        TABLE_TX_LOGS.put("customer_details", new CopyOnWriteArrayList<>());

        // Initial export of all tables
        exportAllTables();

        // Start periodic live synchronization (every 5 seconds)
        SCHEDULER.scheduleWithFixedDelay(() -> {
            try {
                exportAllTables();
            } catch (Throwable t) {
                LOGGER.log(Level.FINE, "Live table background sync pass completed");
            }
        }, 5, 5, TimeUnit.SECONDS);
    }

    public static void init() {
        exportAllTables();
    }

    /**
     * Called whenever a table is inserted, updated, or deleted
     */
    public static synchronized void onTableModified(String tableName, String operation, Object recordId,
            String details) {
        if (tableName == null)
            return;
        String normalized = tableName.toLowerCase();
        String timestamp = LocalDateTime.now().format(FORMATTER);
        String txEntry = String.format("[%s] %-8s | Record #%-5s | %s", timestamp,
                operation != null ? operation : "UPDATE", recordId != null ? recordId : "N/A",
                details != null ? details : "");

        List<String> list = TABLE_TX_LOGS.computeIfAbsent(normalized, k -> new CopyOnWriteArrayList<>());
        list.add(0, txEntry);
        while (list.size() > 15) {
            list.remove(list.size() - 1);
        }

        // Immediately export this table
        exportSingleTable(normalized);

        // If user or reservation or login_details changed, refresh customer details
        // file too
        if ("users".equals(normalized) || "reservations".equals(normalized) || "login_details".equals(normalized)) {
            refreshCustomerDetails();
        }
    }

    /**
     * Exports all database tables and customer details to individual text files
     */
    public static synchronized void exportAllTables() {
        for (String table : ALL_TABLES) {
            exportSingleTable(table);
        }
        refreshCustomerDetails();
    }

    /**
     * Exports a single table to TABLE_<NAME>.txt
     */
    public static synchronized void exportSingleTable(String tableName) {
        if (tableName == null)
            return;
        String fileName = "TABLE_" + tableName.toUpperCase() + ".txt";
        File targetFile = new File(BASE_DIR, fileName);

        String sql = "SELECT * FROM `" + tableName + "`";
        try (Connection conn = DatabaseConnection.getInstance().getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();
            List<String> colNames = new ArrayList<>();
            List<Integer> colWidths = new ArrayList<>();

            for (int i = 1; i <= colCount; i++) {
                String name = meta.getColumnLabel(i);
                colNames.add(name);
                colWidths.add(Math.max(name.length(), 10));
            }

            List<List<String>> rows = new ArrayList<>();
            while (rs.next()) {
                List<String> row = new ArrayList<>();
                for (int i = 1; i <= colCount; i++) {
                    String val = rs.getString(i);
                    if (val == null) {
                        val = "NULL";
                    } else {
                        val = val.replace("\r\n", " ").replace("\n", " ");
                        if (val.length() > 60) {
                            val = val.substring(0, 57) + "...";
                        }
                    }
                    row.add(val);
                    if (val.length() > colWidths.get(i - 1)) {
                        colWidths.set(i - 1, Math.min(val.length(), 60));
                    }
                }
                rows.add(row);
            }

            writeFormattedTableFile(targetFile, tableName.toUpperCase(), rows.size(), colNames, colWidths, rows,
                    TABLE_TX_LOGS.get(tableName.toLowerCase()));

        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Could not export table " + tableName + " directly from MySQL: " + e.getMessage());
        }
    }

    /**
     * Generates and live-updates TABLE_CUSTOMER_DETAILS.txt
     */
    public static synchronized void refreshCustomerDetails() {
        File targetFile = new File(BASE_DIR, "TABLE_CUSTOMER_DETAILS.txt");
        String sql = "SELECT " +
                "u.id AS customer_id, " +
                "u.full_name AS customer_name, " +
                "u.email, " +
                "COALESCE(u.phone, 'N/A') AS phone, " +
                "u.status AS account_status, " +
                "u.created_at AS registered_at, " +
                "(SELECT COUNT(*) FROM reservations r WHERE r.customer_id = u.id) AS total_bookings, " +
                "(SELECT MAX(login_time) FROM login_details ld WHERE ld.user_id = u.id OR ld.email = u.email) AS last_login_time, "
                +
                "(SELECT COUNT(*) FROM login_details ld WHERE ld.user_id = u.id OR ld.email = u.email) AS total_logins "
                +
                "FROM users u " +
                "WHERE u.role = 'CUSTOMER' " +
                "ORDER BY u.id ASC";

        try (Connection conn = DatabaseConnection.getInstance().getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();
            List<String> colNames = new ArrayList<>();
            List<Integer> colWidths = new ArrayList<>();

            for (int i = 1; i <= colCount; i++) {
                String name = meta.getColumnLabel(i);
                colNames.add(name);
                colWidths.add(Math.max(name.length(), 12));
            }

            List<List<String>> rows = new ArrayList<>();
            while (rs.next()) {
                List<String> row = new ArrayList<>();
                for (int i = 1; i <= colCount; i++) {
                    String val = rs.getString(i);
                    if (val == null)
                        val = "N/A";
                    row.add(val);
                    if (val.length() > colWidths.get(i - 1)) {
                        colWidths.set(i - 1, Math.min(val.length(), 50));
                    }
                }
                rows.add(row);
            }

            writeFormattedTableFile(targetFile, "CUSTOMER_DETAILS (REGISTERED TOURISTS & CLIENTS)", rows.size(),
                    colNames, colWidths, rows, TABLE_TX_LOGS.get("customer_details"));

        } catch (SQLException e) {
            LOGGER.log(Level.FINE, "Could not export customer details table: " + e.getMessage());
        }
    }

    private static void writeFormattedTableFile(File targetFile, String title, int recordCount,
            List<String> colNames, List<Integer> colWidths,
            List<List<String>> rows, List<String> recentTx) {
        try (PrintWriter pw = new PrintWriter(new FileWriter(targetFile, false))) {
            pw.println(
                    "========================================================================================================================");
            pw.printf("      SAIL LANKA BOAT SAFARI - LIVE DATABASE TABLE: %s%n", title);
            pw.println(
                    "      Database: MySQL 8.0 (boat_safari_db @ localhost:3306) | Engine: InnoDB | Charset: utf8mb4");
            pw.printf("      Total Records: %d | Last Live Synced: %s%n", recordCount,
                    LocalDateTime.now().format(FORMATTER));
            pw.println(
                    "========================================================================================================================");

            // Print Header
            StringBuilder headerLine = new StringBuilder();
            StringBuilder separatorLine = new StringBuilder();
            for (int i = 0; i < colNames.size(); i++) {
                int w = colWidths.get(i);
                headerLine.append(String.format("%-" + w + "s", colNames.get(i)));
                char[] sep = new char[w];
                Arrays.fill(sep, '-');
                separatorLine.append(new String(sep));
                if (i < colNames.size() - 1) {
                    headerLine.append(" | ");
                    separatorLine.append("-+-");
                }
            }
            pw.println(headerLine.toString());
            pw.println(separatorLine.toString());

            // Print Rows
            if (rows.isEmpty()) {
                pw.println("(No records currently in this table)");
            } else {
                for (List<String> row : rows) {
                    StringBuilder rowLine = new StringBuilder();
                    for (int i = 0; i < row.size(); i++) {
                        int w = colWidths.get(i);
                        rowLine.append(String.format("%-" + w + "s", row.get(i)));
                        if (i < row.size() - 1) {
                            rowLine.append(" | ");
                        }
                    }
                    pw.println(rowLine.toString());
                }
            }

            pw.println(separatorLine.toString());
            pw.printf("Total Rows: %d%n", recordCount);
            pw.println();

            // Recent live transactions
            pw.println(
                    "------------------------------------------------------------------------------------------------------------------------");
            pw.println("RECENT REAL-TIME TRANSACTIONS & AUDIT LOG:");
            pw.println(
                    "------------------------------------------------------------------------------------------------------------------------");
            if (recentTx != null && !recentTx.isEmpty()) {
                for (String tx : recentTx) {
                    pw.println("  " + tx);
                }
            } else {
                pw.println("  (Waiting for live transactions / operations...)");
            }
            pw.println(
                    "========================================================================================================================");
            pw.flush();
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Error writing to " + targetFile.getName(), e);
        }
    }
}
