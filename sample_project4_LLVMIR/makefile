all: myCompiler myCompiler_test

myCompiler: myCompiler.g
	java -cp antlr-3.5.3-complete.jar org.antlr.Tool myCompiler.g
myCompiler_test: myCompilerParser.java myCompilerLexer.java myCompiler_test.java
	javac -cp antlr-3.5.3-complete.jar myCompiler_test.java myCompilerParser.java myCompilerLexer.java

test0: test0.c
	java -cp antlr-3.5.3-complete.jar:. myCompiler_test test0.c
test1: test1.c
	java -cp antlr-3.5.3-complete.jar:. myCompiler_test test1.c
test2: test2.c
	java -cp antlr-3.5.3-complete.jar:. myCompiler_test test2.c
test3: test3.c
	java -cp antlr-3.5.3-complete.jar:. myCompiler_test test3.c

clean:
	rm *.class myCompilerParser.java myCompilerLexer.java myCompiler.tokens