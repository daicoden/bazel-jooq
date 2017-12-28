package bazeljooq.sqldatabase;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

public class CreateMysqlDatabase {

    // write true to outfile for now
    public static void main(String[] args) throws IOException {
        // Must be, host, port, username, password
        if (args.length != 5) {
            System.out.println("Usage: <script> host port username password out-file");
            System.exit(-1);
        }

        System.out.println(String.format("success %s", Arrays.asList(args)));
        System.out.println(args[4]);
        BufferedWriter file = Files.newBufferedWriter(Paths.get(args[4]));
        file.write("true");
    }
}
