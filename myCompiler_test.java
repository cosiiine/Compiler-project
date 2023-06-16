import org.antlr.runtime.*;
import java.util.ArrayList;
import java.util.List;
import java.io.FileWriter;

public class myCompiler_test {
	public static void main(String[] args) throws Exception {
            CharStream input = new ANTLRFileStream(args[0]);
            myCompilerLexer lexer = new myCompilerLexer(input);
            CommonTokenStream tokens = new CommonTokenStream(lexer);
      
            myCompilerParser parser = new myCompilerParser(tokens);
            parser.program();
            
            /* Output text section */
            List<String> text_code = parser.getTextCode();

            String file = args[0].substring(0, args[0].length() - 1) + "ll";
            FileWriter fd = new FileWriter(file);
            System.out.println("=== TextCode ===");
            for (int i=0; i < text_code.size(); i++) {
                  System.out.println(text_code.get(i));
                  fd.write(text_code.get(i) + '\n');
            }
            fd.flush();
            fd.close();
      }
}
