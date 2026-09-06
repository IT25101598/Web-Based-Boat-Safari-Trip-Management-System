package com.boatsafari.common.util;

import com.boatsafari.common.dao.LoginDetailsDAO;

import java.io.File;
import java.util.logging.Logger;

/**
 * Adapter and Bridge for Real-Time Live Database Table Operations.
 * Dispatches table modification events to LiveTableManager and records
 * all authentication attempts and sign-ins to the `login_details` table and live text files.
 */
public class LiveFileLogger {
    private static final Logger LOGGER = Logger.getLogger(LiveFileLogger.class.getName());
    private static final LoginDetailsDAO loginDetailsDAO = new LoginDetailsDAO();

    static {
        // Ensure old obsolete files are permanently removed
        String userDir = System.getProperty("user.dir");
        if (userDir != null) {
            new File(userDir, "LIVE_CUSTOMER_SIGNINS.txt").delete();
            new File(userDir, "LIVE_TABLE_UPDATES.txt").delete();
        }
        // Initialize LiveTableManager
        LiveTableManager.init();
    }

    /**
     * Records a login, sign-in, or registration event into the `login_details` table
     * and triggers live updates across TABLE_LOGIN_DETAILS.txt, TABLE_CUSTOMER_DETAILS.txt, and TABLE_USERS.txt.
     */
    public static synchronized void logCustomerSignIn(String action, int userId, String name, String email, String role, String ipAddress, String status) {
        // Record into `login_details` table
        loginDetailsDAO.recordLogin(
                userId > 0 ? userId : null,
                name != null ? name : "Guest",
                email != null ? email : "unknown@guest.lk",
                role != null ? role : "CUSTOMER",
                ipAddress != null ? ipAddress : "127.0.0.1",
                status != null ? status : "SUCCESS",
                action + " - " + (status != null ? status : "")
        );

        // Notify table modifications
        LiveTableManager.onTableModified("login_details", "INSERT", userId, "Sign-in action=" + action + " for " + name + " (" + email + ")");
        LiveTableManager.onTableModified("users", "AUTH_" + action, userId, "Auth state updated for " + email);
        LiveTableManager.refreshCustomerDetails();
    }

    /**
     * Notifies live file manager of a database table modification (INSERT, UPDATE, DELETE).
     */
    public static synchronized void logTableUpdate(String tableName, String operation, Object recordId, String details) {
        LiveTableManager.onTableModified(tableName, operation, recordId, details);
    }
}
