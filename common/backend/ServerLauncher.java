package com.boatsafari.common;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * 1-Click Embedded Tomcat 10 Server Launcher.
 * Allows running the entire Boat Safari Management System without external Tomcat configuration.
 * Command: mvn compile exec:java or Run in IntelliJ IDEA.
 */
public class ServerLauncher {
    private static final int PORT = 8080;

    public static void main(String[] args) throws Exception {
        String webappDirLocation = "src/main/webapp";
        File webappDir = new File(webappDirLocation);
        if (!webappDir.exists()) {
            webappDir = new File(".", "src/main/webapp");
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(PORT);
        tomcat.getConnector(); // Trigger connector initialization

        // Enable JSP compilation & annotations
        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir.getAbsolutePath());
        ctx.setParentClassLoader(ServerLauncher.class.getClassLoader());
        ctx.setDelegate(true);
        ctx.setReloadable(true);

        // Map target/classes to webapp classloader
        File additionWebInfClasses = new File("target/classes");
        if (additionWebInfClasses.exists()) {
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));
            ctx.setResources(resources);
        }

        System.out.println("====================================================================");
        System.out.println("  SLIIT SE2030 - BOAT SAFARI TRIP MANAGEMENT SYSTEM");
        System.out.println("  Group: Y2-S1-MLB-B8G1-09");
        System.out.println("  Inspired by Sail Lanka Charter (sail-lanka-charter.com)");
        System.out.println("  Embedded Tomcat Server is running at: http://localhost:" + PORT + "/");
        System.out.println("====================================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}
