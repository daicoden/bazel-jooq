package bazeljooq.sqldatabase;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class CreateDatabase {

    // write true to outfile for now
    public static void main(String[] args)
            throws IOException, SQLException, ClassNotFoundException, IllegalAccessException, InstantiationException {
        // Must be, host, port, username, password
        if (args.length != 6) {
            System.out.println("Usage: <script> jdbc-connection-string username password driver-class database out-file");
            System.exit(-1);
        }

        String connectionString = args[0];
        String username = args[1].isEmpty() ? null : args[1];
        String password = args[2].isEmpty() ? null : args[2];
        String driverClass = args[3];
        String dbname = args[4];
        String out = args[5];

        // new Driver()
        // Driver must be accessable on the class path
        CreateDatabase.class.getClassLoader().loadClass(driverClass).newInstance();

        Connection conn = null;
        Statement statement = null;
        boolean success = false;
        try {
            conn = DriverManager.getConnection(connectionString, username, password);
            statement = conn.createStatement();
            statement.executeUpdate(String.format("CREATE DATABASE IF NOT EXISTS %s", dbname));
            success = true;
        } finally {
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException ignore) {
                }
            }

            if (conn != null) {
                 try {
                    conn.close();
                } catch (SQLException ignore) {
                }
            }
        }

        BufferedWriter file = Files.newBufferedWriter(Paths.get(out));
        if (!success) {
            System.out.println("Could not create database");
            System.exit(-1);
        }
        file.write("true");
        file.close();
    }
}
