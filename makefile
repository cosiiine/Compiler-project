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
ll0: test0.ll
	/usr/lib/llvm-10/bin/lli test0.ll
ll1: test1.ll
	/usr/lib/llvm-10/bin/lli test1.ll
ll2: test2.ll
	/usr/lib/llvm-10/bin/lli test2.ll
ll3: test3.ll
	/usr/lib/llvm-10/bin/lli test3.ll
s0: test0.c
	clang -S -emit-llvm test0.c
	more test0.ll
s1: test1.c
	clang -S -emit-llvm test1.c
	more test1.ll
s2: test2.c
	clang -S -emit-llvm test2.c
	more test2.ll
s3: test3.c
	clang -S -emit-llvm test3.c
	more test3.ll

clean:
	rm *.class myCompilerParser.java myCompilerLexer.java myCompiler.tokens *.ll