系級：資工三
姓名：胡妤嫻
學號：409410104

作業資料夾內包含：
    1. myChecker.g
    2. myChecker_test.java
    3. test file: test1.c, test2.c, test3.c
    4. README.txt
    5. makefile
    6. describe file: 409410104.pdf
    7. antlr-3.5.3-complete.jar

如何執行檔案：

    "make":
        java -cp antlr-3.5.3-complete.jar org.antlr.Tool myChecker.g
        javac -cp antlr-3.5.3-complete.jar myChecker_test.java myCheckerParser.java myCheckerLexer.java
        => 生成 myCheckerParser.java, myCheckerLexer.java, myChecker.tokens
        => 編譯 myChecker_test.java myCheckerParser.java myCheckerLexer.java

    "make test1":
        java -cp antlr-3.5.3-complete.jar:. myChecker_test test1.c
        => 測試 test1.c

    "make test2":
        java -cp antlr-3.5.3-complete.jar:. myChecker_test test2.c
        => 測試 test2.c

    "make test3":
        java -cp antlr-3.5.3-complete.jar:. myChecker_test test3.c
        => 測試 test3.c

    "make clean":
        rm *.class myCheckerParser.java myCheckerLexer.java myChecker.tokens
        => 刪除所有編譯執行而生成的檔案