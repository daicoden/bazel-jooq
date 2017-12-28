package bazeljooq.sqldatabase;

import com.mysql.cj.jdbc.Driver;
import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class CreateMysqlDatabase {

    // write true to outfile for now
    public static void main(String[] args) throws IOException, SQLException {
        // Must be, host, port, username, password
        if (args.length != 6) {
            System.out.println("Usage: <script> host port username password database out-file");
            System.exit(-1);
        }

        new Driver();
        String host = args[0];
        String port = args[1];
        String username = args[2];
        String password = args[3];
        String dbname = args[4];
        String out = args[5];

        String url = String.format("jdbc:mysql://%s:%s", host, port);
        Connection conn = null;
        Statement statement = null;
        boolean success = false;
        try {
            conn = DriverManager.getConnection(url, username, password);
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
