package bazeljooq.sqldatabase;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class CreateDatabase {

    // From: https://memorynotfound.com/calculate-file-checksum-java/
    public enum Hash {
        SHA256("SHA-256");

        private String name;

        Hash(String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public String checksum(InputStream in) {
            try {
                MessageDigest digest = MessageDigest.getInstance(getName());
                byte[] block = new byte[4096];
                int length;
                while ((length = in.read(block)) > 0) {
                    digest.update(block, 0, length);
                }
                return bytesToHex(digest.digest());
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }

        // from: https://stackoverflow.com/questions/15429257/how-to-convert-byte-array-to-hexstring-in-java
        private String bytesToHex(byte[] in) {
            final StringBuilder builder = new StringBuilder();
            for(byte b : in) {
                builder.append(String.format("%02x", b));
            }
            return builder.toString();
        }
    }


    // write true to outfile for now
    public static void main(String[] args)
            throws IOException, SQLException, ClassNotFoundException, IllegalAccessException, InstantiationException {
        if (args.length != 6) {
            System.out
                    .println("Usage: <script> jdbc-connection-string username password driver-class database out-file");
            System.exit(-1);
        }

        String connectionString = args[0];
        String username = args[1].isEmpty() ? null : args[1];
        String password = args[2].isEmpty() ? null : args[2];
        String driverClass = args[3];
        String dbname = args[4];
        String out = args[5];

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
        } catch(RuntimeException e) {
            System.out.println("Could not create database");
            System.exit(-1);
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
        String toolSha = Hash.SHA256.checksum(Files.newInputStream(
                Paths.get(CreateDatabase.class.getProtectionDomain().getCodeSource().getLocation().getPath()),
                StandardOpenOption.READ));

        file.write(toolSha);
        file.close();
    }
}
