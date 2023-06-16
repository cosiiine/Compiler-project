grammar myCompiler;

options {
    language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;
    boolean MAIN = false;
    int labelCount = 0;
    int varCount = 0;
    int strCount = 0;
    List<String> TextCode = new ArrayList<String>();
    String place = "";

    public List<String> getTextCode() {
       	return TextCode;
    }
    public enum Type {
        Void,
        Char,
        String,
        Short,
        Int,
        Long,
        Float,
        Double,
        Signed,
        Unsigned,
        Bool,
        Unknown,
        NoExist,
        Error
    }
	class tVar {
		int   varIndex; // temporary variable's index.
		int   iValue;   // value of constant integer.
		float fValue;   // value of constant floating point.
	};
	class Info {
		Type theType;
		tVar theVar;
        private String name;
		Info() {
            theType = Type.Error;
            theVar = new tVar();
            theVar.varIndex = -1;
		}
        void set(Type type, int index, String str) {
            theType = type;
            theVar.varIndex = index;
            if (index == -1) {
                if (type == Type.Float) theVar.fValue = Float.parseFloat(str);
                else theVar.iValue = Integer.parseInt(str);
            } else if (index == -2) {
                name = str;
            } else name = "\%t" + Integer.toString(index);
        }
        String getValue() {
            if (theType == Type.Error) return "ERR";
            if (theVar.varIndex == -1) {
                switch (theType) {
                    case Char:
                    case Short:
                    case Int:
                    case Signed:
                    case Unsigned:
                    case Long:
                        return Integer.toString(theVar.iValue);
                    case Float:
                    case Double:
                        return String.format("\%.6e", theVar.fValue);
                        // return Integer.toHexString(Float.floatToIntBits(theVar.fValue));
                }
            }
            return name;
        }
        String getType() {
            switch (theType) {
                case Void:
                    return "void";
                case Char:
                    return "i8";
                case Short:
                    return "i16";
                case Int:
                case Signed:
                case Unsigned:
                    return "i32";
                case Long:
                    return "i64";
                case Float:
                    return "float";
                case Double:
                    return "double";
            }
            return "ERR";
        }
        int getAlign() {
            switch (theType) {
                case Char:
                    return 1;
                case Short:
                    return 2;
                case Int:
                case Signed:
                case Unsigned:
                case Float:
                    return 4;
                case Long:
                case Double:
                    return 8;
            }
            return 0;
        }
        int getAlign(Type type) {
            switch (type) {
                case Char:
                    return 1;
                case Short:
                    return 2;
                case Int:
                case Signed:
                case Unsigned:
                case Float:
                    return 4;
                case Long:
                case Double:
                    return 8;
            }
            return 0;
        }
	};
	class Env {
		private HashMap<String, Info> table;
		protected Env prev;

		public Env(Env p) {
			table = new HashMap<String, Info>();
			prev = p;
		}
        public Info set(String s) {
            return table.get(s);
        }
		public void put(String s, Info info) {
			table.put(s, info);
		}
		public Info get(String s) {
			for (Env e = this; e != null; e = e.prev) {
				Info found = (Info)(e.table.get(s));
				if (found != null) return found;
			}
            return null;
		}
	};
    String newLabel() {
		labelCount ++;
		return (new String("L")) + Integer.toString(labelCount);
    }
	
    Env top = new Env(null), saved;
    Info declare(String text, Type type, int line) {
        if (top.set(text) != null) System.out.println("Error! " + line + ": Redeclared identifier.");
        else {
            Info theEntry = new Info();
            theEntry.theType = type;
            if (top.prev == null) {
                theEntry.set(type, -2, "@" + text);
            } else {
                theEntry.set(type, varCount++, "");
            }
            top.put(text, theEntry);
            return theEntry;
        }
        return new Info();
    }
    Info load(Info a) {
        Info theInfo = new Info();
        theInfo.set(a.theType, varCount++, "");
        TextCode.add(theInfo.getValue() + " = load " + a.getType() + ", " + a.getType() + "* " + a.getValue() + ", align " + a.getAlign());
        return theInfo;
    }
    Info assign(String op, Info a, Info b) {
        Info theInfo = new Info();
        if (a.getType() != b.getType()) return theInfo;
        theInfo.set(a.theType, varCount++, "");
        TextCode.add(theInfo.getValue() + " = " + op + " " + a.getType() + " " + a.getValue() + ", " + b.getValue());
        return theInfo;
    }
    void store(Info var, Info a) {
        TextCode.add("store " + a.getType() + " " + var.getValue() + ", " + a.getType() + "* " + a.getValue() + ", align " + a.getAlign());
    }
}

/* Start */
program
    :   external_declaration+
        {
			if (TRACEON) System.out.println("program\t\t\t: external_declaration+");
			if (!MAIN) System.out.println("Error!: Undefined reference to 'main'.");
            TextCode.add("declare dso_local i32 @printf(i8*, ...)");
		}
    ;
/* Declaration */
external_declaration
    :   function_definition
        { if (TRACEON) System.out.println("external_declaration\t: function_definition\n"); }
    |   declaration
        { if (TRACEON) System.out.println("external_declaration\t: declaration\n"); }
    |   ';'
        { if (TRACEON) System.out.println("external_declaration\t: ';'\n"); }
    ;
declaration
    :   type init_declarator_list[$type.attr_type] ';'
        { if (TRACEON) System.out.println("declaration\t\t: type init_declarator_list ';'"); }
    ;
init_declarator_list
[Type attr_type]
    :   init_declarator[$attr_type] (',' init_declarator[$attr_type])*
        { if (TRACEON) System.out.println("init_declarator_list\t: init_declarator (',' init_declarator)*"); }
    ;
init_declarator
[Type attr_type]
    :   (   a = ID
            {
                Info theEntry = declare($a.text, $attr_type, $a.getLine());
                if (top.prev == null) {
                    if (theEntry.theType == Type.Float) TextCode.add(theEntry.getValue() + " = common dso_local global " + theEntry.getType() + " 0.000000e+00, align " + theEntry.getAlign());
                    else TextCode.add(theEntry.getValue() + " = common dso_local global " + theEntry.getType() + " 0, align " + theEntry.getAlign());
                } else {
                    TextCode.add(theEntry.getValue() + " = alloca " + theEntry.getType() + ", align " + theEntry.getAlign());
                }
            }
        |   b = ID '=' initializer
            {
                Info theEntry = declare($b.text, $attr_type, $b.getLine());
                if (theEntry.theType == Type.Error && $attr_type != $initializer.theInfo.theType) {
                    System.out.println("Error! " + $b.getLine() + ": Type mismatch for the operator = in a declaration.");
                } else {
                    if (top.prev == null) {
                        TextCode.add(theEntry.getValue() + " = dso_local global " + theEntry.getType() + " " + $initializer.theInfo.getValue() + ", align " + theEntry.getAlign());
                    } else {
                        TextCode.add(theEntry.getValue() + " = alloca " + theEntry.getType() + ", align " + theEntry.getAlign());
                        store($initializer.theInfo, theEntry);
                    }
                }
            }
        )   { if (TRACEON) System.out.println("init_declarator\t\t: ID ('=' initializer)?"); }
    ;
initializer
returns [Info theInfo]
    :   assignment_expression
        {
			if (TRACEON) System.out.println("initializer\t\t: assignment_expression");
            $theInfo = $assignment_expression.theInfo;
		}
	;
/* Function */
function_definition
returns [String define]
    :   type ID
        {
            varCount = 0;
            Info theInfo = declare($ID.text, $type.attr_type, $ID.getLine());
            define = "define dso_local " + theInfo.getType() + " " + theInfo.getValue() + "(";
            place = $ID.text;
            if (place.equals("main")) MAIN = true;
            saved = top;
            top = new Env(top);
		} '(' parameter_list ')'
        {   
            for (int i = 0; i < $parameter_list.param.size(); i++) {
                if (i > 0) define += ", ";
                define += $parameter_list.param.get(i).getType() + " " + $parameter_list.param.get(i).getValue();
            }
            TextCode.add($function_definition.define + ") {");
            for (int i = 0; i < $parameter_list.param.size(); i++) {
                Info theInfo = declare($parameter_list.name.get(i), $parameter_list.param.get(i).theType, $parameter_list.start.getLine());
                TextCode.add(theInfo.getValue() + " = alloca " + theInfo.getType() + ", align " + theInfo.getAlign());
                store($parameter_list.param.get(i), theInfo);
            }
        }
        '{' ( compound )* '}'
		{	
            top = saved;
            place = "";
            TextCode.add("}");
			if (TRACEON) System.out.println("function_definition\t: type ID '(' parameter_type_list ')' '{' ( compound )* '}'");
		}
    ;
parameter_list
returns [List<Info> param, List<String> name]
    :   { $param = new ArrayList<Info>(); $name = new ArrayList<String>(); }
	(   a = parameter_declaration      { $param.add($a.theInfo); $name.add($a.name); }
        (',' b = parameter_declaration { $param.add($b.theInfo); $name.add($b.name); })*
        { if (TRACEON) System.out.println("parameter_list\t\t: parameter_declaration (',' parameter_declaration)*"); }
	|	)
	;
parameter_declaration
returns [Info theInfo, String name]
	:   type ID
        {	
			if (TRACEON) System.out.println("parameter_declaration\t: type ID");
			$theInfo = new Info();
            $theInfo.set($type.attr_type, varCount++, "");
            $name = $ID.text;
		}
	;
/* Statements */
block
    :   statement[newLabel()]
    ;

statement
[String label]
returns [String next]
    :   { $next = label; }
    (   compound_statement
        { if (TRACEON) System.out.println("statement\t\t: compound_statement"); }
    |   expression_statement
        { if (TRACEON) System.out.println("statement\t\t: expression_statement"); }
    |   if_statement[$next]
        { if (TRACEON) System.out.println("statement\t\t: if_statement"); }
    |   while_statement[$next]
        { if (TRACEON) System.out.println("statement\t\t: while_statement"); }
    |   for_statement[$next]
        { if (TRACEON) System.out.println("statement\t\t: for_statement"); }
    |   switch_statement
        { if (TRACEON) System.out.println("statement\t\t: switch_statement"); }
    |   jump_statement[$next]
        { if (TRACEON) System.out.println("statement\t\t: jump_statement"); }
    |   printf_statement
        { if (TRACEON) System.out.println("statement\t\t: printf_statement"); }
    |	';'
        { if (TRACEON) System.out.println("statement\t\t: ';'"); }
    )
    ;
compound_statement
    :   '{' { saved = top; }
        ( compound )* 
        '}' { top = saved; }
        { if (TRACEON) System.out.println("compound_statement\t: '{' ( declaration | statement )* '}'"); }
    ;
compound
	:	declaration | block
	;
expression_statement
    :   expression ';'
        { if (TRACEON) System.out.println("expression_statement\t: expression ';'"); }
    ;
if_statement
[String next]
returns [String t, String f]
    :   'if' '(' expression ')'
        {
			if ($expression.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $if_statement.start.getLine() + ": Type mismatch in a if_statement's condition.");
			} else {
                $t = newLabel();
                $f = newLabel();
                TextCode.add("br i1 " + $expression.theInfo.getValue() + ", label \%" + $t + ", label \%" + $f);
                TextCode.add("");
                TextCode.add($t + ":");
            }
        } block { TextCode.add("br label \%" + $next); TextCode.add(""); TextCode.add($f + ":"); }
        (('else') =>  else_statement)? { TextCode.add("br label \%" + $next); TextCode.add(""); }
        {   
            if (TRACEON) System.out.println("if_statement\t\t: if ( expression ) statement");
            TextCode.add($next + ":");
        }
    ;
else_statement
    :   'else' block
        { if (TRACEON) System.out.println("else_statement\t\t: else statement"); }
    ;
while_statement
[String next]
returns [String l]
    :   { $l = newLabel(); TextCode.add("br label \%" + $l); TextCode.add($l + ":"); TextCode.add(""); }
    (   'do' block 'while' '(' a = expression ')' ';'
        {
			if (TRACEON) System.out.println("while_statement\t\t: do statement while ( expression ) ;");
			
			if ($a.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			} else {
                TextCode.add("br i1 " + $a.theInfo.getValue() + ", label \%" + $l + ", label \%" + $next);
                TextCode.add("");
                TextCode.add($next + ":");
            }
		}
    |   'while' '(' b = expression ')'
        {
			if (TRACEON) System.out.println("while_statement\t\t: while ( expression ) statement");
			
			if ($b.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			} else {
                String lb = newLabel();
                TextCode.add("br i1 " + $b.theInfo.getValue() + ", label \%" + lb + ", label \%" + $next);
                TextCode.add("");
                TextCode.add(lb + ":");
            }
		} block { TextCode.add("br label \%" + $l); TextCode.add(""); TextCode.add($next + ":"); }
    )
    ;
for_statement
[String next]
returns [String la, String lb, String lc]
    :   { $la = newLabel(); $lb = newLabel(); $lc = newLabel(); }
        'for' '(' expression_statement { TextCode.add("br label \%" + $la); TextCode.add(""); TextCode.add($la + ":"); }
        a = expression ';'  
        {   
            if ($a.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $for_statement.start.getLine() + ": Type mismatch in a for_statement's condition.");
			} else {
                TextCode.add("br i1 " + $a.theInfo.getValue() + ", label \%" + $lc + ", label \%" + $next);
                TextCode.add("");
                TextCode.add($lb + ":");
            }
        }
        expression? ')' { TextCode.add("br label \%" + $la); TextCode.add(""); TextCode.add($lc + ":"); }
        block           { TextCode.add("br label \%" + $lb); TextCode.add(""); TextCode.add($next + ":"); }
        { if (TRACEON) System.out.println("for_statement\t\t: 'for' '(' expression_statement expression ';' expression? ')' statement"); }
    ;
switch_statement
    :   'switch' '(' expression ')' '{' (labeled_statement[$expression.theInfo.theType])* '}'
        { if (TRACEON) System.out.println("switch_statement\t: switch ( expression ) { labeled_statement* }"); }
    ;
labeled_statement
[Type attr_type]
	:   'case' conditional_expression ':' block*
        {
			if (TRACEON) System.out.println("labeled_statement\t: 'case' conditional_expression ':' statement*");
			
			if ($conditional_expression.theInfo.theType != $attr_type) {
				System.out.println("Error! " + $labeled_statement.start.getLine() + ": Type mismatch in a labeled_statement.");
			}
		}
	|   'default' ':' block*
        { if (TRACEON) System.out.println("labeled_statement\t: 'default' ':' statement*"); }
	;
jump_statement
[String next]
	:   'goto' ID ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: goto ID");
			if (top.get($ID.text) == null) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
			}
		}
	|   'continue' ';'          { if (TRACEON) System.out.println("jump_statement\t\t: continue;"); }
	|   'break' ';'             { if (TRACEON) System.out.println("jump_statement\t\t: break;"); }
	|   'return' expression ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: 'return' expression ';'");
			if (top.get(place).theType != $expression.theInfo.theType) {
				System.out.println("Error! " + $expression.start.getLine() + ": Return wrong type.");
			} else { TextCode.add("ret " + $expression.theInfo.getType() + " " + $expression.theInfo.getValue()); }
		}
	|	'return' ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: 'return' ';'");
			if (top.get(place).theType != Type.Void) {
				System.out.println("Error! " + $jump_statement.start.getLine() + ": Return wrong type.");
			} else { TextCode.add("ret void"); }
		}
	;
printf_statement
returns [String call]
    :   'printf' '(' LITERAL
        {
            String str = "[" + $LITERAL.text.length() + " x i8]";
            TextCode.add(strCount, "@.str." + Integer.toString(strCount) + " = private unnamed_addr constant " + str +" c" + $LITERAL.text.substring(0, $LITERAL.text.length() - 1) + "\\0A\\00\"");
            $call = "\%t" + Integer.toString(varCount) + " = call i32 (i8*, ...) @printf(i8* getelementptr inbounds (" + str + ", " + str + "* @.str." + Integer.toString(strCount) + ", i64 0, i64 0)";
            strCount++; varCount++;
        }
		(	',' assignment_expression
			{
                if ($assignment_expression.theInfo.theType != Type.Error) {
                    if ($assignment_expression.theInfo.theType == Type.Float) {
                        Info theInfo = new Info();
                        theInfo.set(Type.Float, varCount++, "");
                        TextCode.add(theInfo.getValue() + " = fpext float " + $assignment_expression.theInfo.getValue() + " to double");
                        call += ", double " + theInfo.getValue();
                    } else {
                        call += ", " + $assignment_expression.theInfo.getType() + " " + $assignment_expression.theInfo.getValue();
                    }
                }
			}
		)* ')' ';'
        {
            if (TRACEON) System.out.println("printf_statement\t: printf ( LITERAL (, assignment_expression)* );");
            TextCode.add(call + ")");
        }
    ;
/* Expression */
expression
returns [Info theInfo]
    :   a = assignment_expression       { $theInfo = $a.theInfo; } 
		(',' b = assignment_expression  { $theInfo = $b.theInfo; } )*
        { if (TRACEON) System.out.println("expression\t\t: assignment_expression (',' assignment_expression)*"); }
    ;
assignment_expression
returns [Info theInfo]
	:   ID
        {
            if (top.get($ID.text) == null) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
                $theInfo = new Info();
			} else $theInfo = top.get($ID.text);
        }
        assignment_operator[$theInfo.theType] a = assignment_expression
        {
			if (TRACEON) System.out.println("assignment_expression\t: ID assignment_operator assignment_expression");
            if ($theInfo.theType != $a.theInfo.theType) {
                System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the two sides of an assignment.");
                $theInfo = new Info();
            } else {
                if ($assignment_operator.op == "=") {
                    store($a.theInfo, $theInfo);
                } else {
                    Info ans = assign($assignment_operator.op, load($theInfo), $a.theInfo);
                    store(ans, $theInfo);
                }
            }
		}
	|   conditional_expression
        {
			if (TRACEON) System.out.println("assignment_expression\t: conditional_expression");
			$theInfo = $conditional_expression.theInfo;
		}
	;
conditional_expression
returns [Info theInfo]
	: 	logical_or_expression { $theInfo = $logical_or_expression.theInfo; }
		('?' a = conditional_expression ':' b = conditional_expression//////////
			{
				if ($theInfo.theType != Type.Bool || $a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $logical_or_expression.start.getLine() + ": Type mismatch for the operator ? : in an expression.");
					$theInfo.theType = Type.Error;
				}  else {
					// 
				}
			}
		)?
        { if (TRACEON) System.out.println("conditional_expression\t: logical_or_expression ('?' conditional_expression ':' conditional_expression)?"); }
	;
logical_or_expression
returns [Info theInfo]
	:   a = logical_and_expression { $theInfo = $a.theInfo; }
		(	'||' b = logical_and_expression
			{
				if ($theInfo.theType != Type.Bool || $b.theInfo.theType != Type.Bool) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator || in an expression.");
                    $theInfo.theType = Type.Error;
                } else {
                    $theInfo = assign("or", $theInfo, $b.theInfo);
                }
			}
		)*
        { if (TRACEON) System.out.println("conditional_expression\t: logical_and_expression ('||' logical_and_expression)*"); }
	;
logical_and_expression
returns [Info theInfo]
	:   a = inclusive_or_expression { $theInfo = $a.theInfo; }
		(	'&&' b = inclusive_or_expression
			{
				if ($theInfo.theType != Type.Bool || $b.theInfo.theType != Type.Bool) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator && in an expression.");
                    $theInfo.theType = Type.Error;
                } else {
                    $theInfo = assign("and", $theInfo, $b.theInfo);
                }
			}
		)*
        { if (TRACEON) System.out.println("logical_and_expression\t: inclusive_or_expression ('&&' inclusive_or_expression)*"); }
	;
inclusive_or_expression
returns [Info theInfo]
	:   a = exclusive_or_expression { $theInfo = $a.theInfo; }
		(	'|' b = exclusive_or_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator | in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign("or", $theInfo, $b.theInfo);
                }
			}
		)*
        { if (TRACEON) System.out.println("inclusive_or_expression\t: exclusive_or_expression ('|' exclusive_or_expression)*"); }
	;
exclusive_or_expression
returns [Info theInfo]
	:   a = and_expression { $theInfo = $a.theInfo; }
		(	'^' b = and_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator ^ in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign("xor", $theInfo, $b.theInfo);
                }
			}
		)*
        { if (TRACEON) System.out.println("exclusive_or_expression\t: and_expression ('^' and_expression)*"); }
	;
and_expression
returns [Info theInfo]
	:   a = equality_expression { $theInfo = $a.theInfo; }
		(	'&' b = equality_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator & in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign("and", $theInfo, $b.theInfo);
                }
			}
		)*
        { if (TRACEON) System.out.println("and_expression\t\t: equality_expression ('&' equality_expression)*"); }
	;
equality_expression
returns [Info theInfo]
	:   a = relational_expression { $theInfo = $a.theInfo; }
		(	equality_operator[$theInfo.theType] b = relational_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $equality_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign($equality_operator.op, $theInfo, $b.theInfo);
                    $theInfo.theType = Type.Bool;
                }
			}
		)*
		{ if (TRACEON) System.out.println("equality_expression\t: relational_expression (equality_operator relational_expression)*"); }
	;
relational_expression
returns [Info theInfo]
	:   a = shift_expression { $theInfo = $a.theInfo; }
		(	relational_operator[$theInfo.theType] b = shift_expression
			{ 
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $relational_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign($relational_operator.op, $theInfo, $b.theInfo);
                    $theInfo.theType = Type.Bool;
                }
			}
		)*
        { if (TRACEON) System.out.println("relational_expression\t: shift_expression (relational_operator shift_expression)*"); }
	;
shift_expression
returns [Info theInfo]
    :   a = add_expression { $theInfo = $a.theInfo; }
		(	shift_operator[$theInfo.theType] b = add_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $shift_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign($shift_operator.op, $theInfo, $b.theInfo);
                }
			}
		)* 
        { if (TRACEON) System.out.println("shift_expression\t\t: add_expression (shift_operator add_expression)* "); }
    ;
add_expression
returns [Info theInfo]
    :   a = mult_expression { $theInfo = $a.theInfo; }
		(	add_operator[$theInfo.theType] b = mult_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $add_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign($add_operator.op, $theInfo, $b.theInfo);
                }
			}
		)* 
        { if (TRACEON) System.out.println("add_expression\t\t: mult_expression (add_operator mult_expression)* "); }
    ;
mult_expression
returns [Info theInfo]
    :   a = cast_expression { $theInfo = $a.theInfo; }
		(	mult_operator[$theInfo.theType] b = cast_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $mult_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
                    $theInfo = assign($mult_operator.op, $theInfo, $b.theInfo);
                }
			}
		)* 
        { if (TRACEON) System.out.println("mult_expression\t\t: cast_expression (mult_operator cast_expression)* "); }
    ;
cast_expression
returns [Info theInfo]
    :   '(' type ')' a = cast_expression
        {
            if (TRACEON) System.out.println("cast_expression\t\t: '(' type ')' cast_expression");
            $theInfo.theType = $type.attr_type;
            /////
        }
    |   unary_expression
        {
            if (TRACEON) System.out.println("cast_expression\t\t: unary_expression");
            $theInfo = $unary_expression.theInfo;
        }
    ;
unary_expression
returns [Info theInfo]
@init { theInfo = new Info(); }
    :   postfix_expression
        {   
            if (TRACEON) System.out.println("unary_expression\t: postfix_expression");
            $theInfo = $postfix_expression.theInfo;
        }
	|   '++' a = unary_expression/////
        {   
            if (TRACEON) System.out.println("unary_expression\t: '++' unary_expression");
            Info one = new Info();
            if ($a.theInfo.theType == Type.Char) one.set(Type.Int, -1, "1");
            else one.set($a.theInfo.theType, -1, "1");
            if ($a.theInfo.theType == Type.Float) $theInfo = assign("fadd", $a.theInfo, one);
            else $theInfo = assign("add", $a.theInfo, one);
        }
	|   '--' b = unary_expression
        {   
            if (TRACEON) System.out.println("unary_expression\t: '--' unary_expression");
            Info one = new Info();
            if ($b.theInfo.theType == Type.Char) one.set(Type.Int, -1, "1");
            else one.set($b.theInfo.theType, -1, "1");
            if ($b.theInfo.theType == Type.Float) $theInfo = assign("fsub", $b.theInfo, one);
            else $theInfo = assign("sub", $b.theInfo, one);
        }
	|   unary_operator cast_expression
        {   /// & * ! /// not finish
            if (TRACEON) System.out.println("unary_expression\t: unary_operator cast_expression");
            Type type = $cast_expression.theInfo.theType;
            if ($unary_operator.op == "-") {
                if (type == Type.Float) {
                    $theInfo.set(type, varCount, "\%t" + Integer.toString(varCount++));
                    TextCode.add($theInfo.getValue() + " = fneg float " + $cast_expression.theInfo.getValue());
                } else if (type == Type.Char) {
                    ///
                } else {
                    Info zero = new Info();
                    zero.set($a.theInfo.theType, -1, "0");
                    $theInfo = assign("sub nuw nsw", zero, $cast_expression.theInfo);
                }
            } else if ($unary_operator.op == "~") {
                if (type == Type.Float) {
                    /// error
                } else if (type == Type.Char) {
                    /// extend
                } else {
                    Info neg = new Info();
                    neg.set($a.theInfo.theType, -1, "-1");
                    $theInfo = assign("xor", $cast_expression.theInfo, neg);
                }
            } else if ($unary_operator.op == "!") {
                ///
            }
        }
	|   'sizeof' c = unary_expression
        {   
            if (TRACEON) System.out.println("unary_expression\t: 'sizeof' unary_expression");
            $theInfo.set(Type.Int, -1, Integer.toString($c.theInfo.getAlign()));
        }
	|   'sizeof' '(' type ')'
        {   
            if (TRACEON) System.out.println("unary_expression\t: 'sizeof' '(' type ')'");
            $theInfo.set(Type.Int, -1, Integer.toString(theInfo.getAlign($type.attr_type)));
        }
	;

postfix_expression
returns [Info theInfo]
@init { theInfo = new Info(); }
	:   primary_expression { $theInfo = $primary_expression.theInfo; }
        (   (	'[' expression ']' ///
			|   '(' ')'
			|   '(' expression ')'
			|   '++'    ///
			|   '--'    ///
			)
		// |   ('.' | '->') ID
        )* { if (TRACEON) System.out.println("postfix_expression\t: primary_expression (('[' expression ']' | '(' ')' | '(' expression ')' | '++' | '--')*"); }
	;

primary_expression
returns [Info theInfo]
    :   ID
        {
			if (TRACEON) System.out.println("primary_expression\t: ID");
			if (top.get($ID.text) == null) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
                $theInfo = new Info();
			}  else {
				$theInfo = load(top.get($ID.text));
			}
		}
    |   constant
        {  
            if (TRACEON) System.out.println("primary_expression\t: constant");
            $theInfo = $constant.theInfo;
        }
    |   '(' expression ')'
        { if (TRACEON) System.out.println("primary_expression\t: '(' expression ')'"); 	$theInfo = $expression.theInfo; }
    ;

/* Definition */
type 				returns [Type attr_type]
    :   'void'      { if (TRACEON) System.out.println("type\t\t\t: 'void'");	$attr_type = Type.Void;	    }
	|   'char'      { if (TRACEON) System.out.println("type\t\t\t: 'char'");	$attr_type = Type.Char;	    }
	|   'short'     { if (TRACEON) System.out.println("type\t\t\t: 'short'");	$attr_type = Type.Short;    }
	|   'int'       { if (TRACEON) System.out.println("type\t\t\t: 'int'");		$attr_type = Type.Int;	    }
	|   'long'      { if (TRACEON) System.out.println("type\t\t\t: 'long'");	$attr_type = Type.Long;	    }
	|   'float'     { if (TRACEON) System.out.println("type\t\t\t: 'float'");	$attr_type = Type.Float;    }
	|   'double'    { if (TRACEON) System.out.println("type\t\t\t: 'double'");	$attr_type = Type.Float;    }
	|   'signed'    { if (TRACEON) System.out.println("type\t\t\t: 'signed' ");	$attr_type = Type.Signed;	}
	|   'unsigned'  { if (TRACEON) System.out.println("type\t\t\t: 'unsigned'");$attr_type = Type.Unsigned;	}
    ;

constant
returns [Info theInfo]
@init { theInfo = new Info(); }
    :   DEC_NUM     { if (TRACEON) System.out.println("constant\t\t: DEC_NUM");		$theInfo.theType = Type.Int;    $theInfo.theVar.iValue = Integer.parseInt($DEC_NUM.text);   }
    |   OCT_NUM     { if (TRACEON) System.out.println("constant\t\t: OCT_NUM");		$theInfo.theType = Type.Int;    $theInfo.theVar.iValue = Integer.valueOf($OCT_NUM.text, 8); }
    |   HEX_NUM     { if (TRACEON) System.out.println("constant\t\t: HEX_NUM"); 	$theInfo.theType = Type.Int;    $theInfo.theVar.iValue = Integer.valueOf($HEX_NUM.text,16); }
    |   FLOAT_NUM   { if (TRACEON) System.out.println("constant\t\t: FLOAT_NUM");	$theInfo.theType = Type.Float;  $theInfo.theVar.fValue = Float.parseFloat($FLOAT_NUM.text); }
    |   CHAR_VAL    { if (TRACEON) System.out.println("constant\t\t: CHAR_VAL");	$theInfo.theType = Type.Char;   $theInfo.theVar.iValue = (int) $CHAR_VAL.text.charAt(1);   }
    |   LITERAL     { if (TRACEON) System.out.println("constant\t\t: LITERAL ");	$theInfo.theType = Type.String; $theInfo.theVar.iValue = -1;   } ///
    ;

assignment_operator     //// System.out.println("Error! " + $a.start.getLine() + ": Operator " + $assignment_operator.op + " does not support " + storeInfo.getType());
[Type attr_type]
returns [String op]
	:   '='     {   if (TRACEON) System.out.println("assignment_operator\t: '='");
                    $op = "=";
                }
	|   '*='    {   if (TRACEON) System.out.println("assignment_operator\t: '*='");
                    if ($attr_type == Type.Float) $op = "fmul";
                    else $op = "mul nuw nsw";
                }
	|   '/='    {   if (TRACEON) System.out.println("assignment_operator\t: '/='");
                    if ($attr_type == Type.Unsigned) $op = "udiv exact";
                    else $op = "sdiv exact";
                }
	|   '%='    {   if (TRACEON) System.out.println("assignment_operator\t: '\%='");
                    if ($attr_type == Type.Float) $op = "frem";
                    else if ($attr_type == Type.Unsigned) $op = "urem";
                    else $op = "srem";
                }
	|   '+='    {   if (TRACEON) System.out.println("assignment_operator\t: '+='");
                    if ($attr_type == Type.Float) $op = "fadd";
                    else $op = "add nuw nsw";
                }
	|   '-='    {   if (TRACEON) System.out.println("assignment_operator\t: '-='");
                    if ($attr_type == Type.Float) $op = "fsub";
                    else $op = "sub nuw nsw";
                }
	|   '<<='   {   if (TRACEON) System.out.println("assignment_operator\t: '<<='");
                    $op = "shl nuw nsw";
                }
	|   '>>='   {   if (TRACEON) System.out.println("assignment_operator\t: '>>='");
                    if ($attr_type == Type.Unsigned) $op = "lshr exact";
                    else $op = "ashr exact";
                }
	|   '&='    {   if (TRACEON) System.out.println("assignment_operator\t: '&='");
                    $op = "and";
                }
	|   '^='    {   if (TRACEON) System.out.println("assignment_operator\t: '^='");
                    $op = "xor";
                }
	|   '|='    {   if (TRACEON) System.out.println("assignment_operator\t: '|='");
                    $op = "or";
                }
	;

equality_operator
[Type attr_type]
returns [String op]
	:	{
            if ($attr_type == Type.Float) $op = "fcmp ";
            else $op = "icmp ";
        }
    (   '==' 	{ if (TRACEON) System.out.println("equality_operator\t: '=='");	$op += "eq";	}
	| 	'!='	{ if (TRACEON) System.out.println("equality_operator\t: '!='");	$op += "ne";	}
    )
    ;

relational_operator
[Type attr_type]
returns [String op]
	:	{
            if ($attr_type == Type.Float) $op = "fcmp ";
            else $op = "icmp ";
        }
    (   '>' 	{   if (TRACEON) System.out.println("relational_operator\t: '>'");
                    if ($attr_type == Type.Unsigned) $op += "ugt";
                    else $op += "sgt";
                }
	| 	'<' 	{   if (TRACEON) System.out.println("relational_operator\t: '<'");
                    if ($attr_type == Type.Unsigned) $op += "ult";
                    else $op += "slt";
                }
	| 	'>=' 	{   if (TRACEON) System.out.println("relational_operator\t: '>='");
                    if ($attr_type == Type.Unsigned) $op += "uge";
                    else $op += "sge";
                }
	| 	'<=' 	{   if (TRACEON) System.out.println("relational_operator\t: '<='");
                    if ($attr_type == Type.Unsigned) $op += "ule";
                    else $op += "sle";
                }
    )
	;

shift_operator
[Type attr_type]
returns [String op]
	:	'>>' 	{   if (TRACEON) System.out.println("shift_operator\t: '>>'");
                    if ($attr_type == Type.Unsigned) $op = "lshr exact";
                    else $op = "ashr exact";
                }
	|	'<<' 	{   if (TRACEON) System.out.println("shift_operator\t: '<<'");
                    $op = "shl nuw nsw";
                }
	;
	
add_operator
[Type attr_type]
returns [String op]
	:	'+'		{   if (TRACEON) System.out.println("add_operator\t: '+'");
                    if ($attr_type == Type.Float) $op = "fadd";
                    else $op = "add nuw nsw";
                }
	|	'-'		{   if (TRACEON) System.out.println("add_operator\t: '-'");
                    if ($attr_type == Type.Float) $op = "fsub";
                    else $op = "sub nuw nsw";
                }
	;

mult_operator
[Type attr_type]
returns [String op]
	:	'*'		{   
                    if (TRACEON) System.out.println("mult_operator\t: '*'");
                    if ($attr_type == Type.Float) $op = "fmul";
                    else $op = "mul nuw nsw";
                }
	|	'/'		{   
                    if (TRACEON) System.out.println("mult_operator\t: '/'");
                    if ($attr_type == Type.Unsigned) $op = "udiv exact";
                    else $op = "sdiv exact";
                }
	|	'%'		{   
                    if (TRACEON) System.out.println("mult_operator\t: '\%'");
                    if ($attr_type == Type.Float) $op = "frem";
                    else if ($attr_type == Type.Unsigned) $op = "urem";
                    else $op = "srem";
                }
	;

unary_operator
returns [String op]
	:   '&' { if (TRACEON) System.out.println("unary_operator\t\t: '&'"); $op = "&"; }///
	|   '*' { if (TRACEON) System.out.println("unary_operator\t\t: '*'"); $op = "*"; }///
	|   '+' { if (TRACEON) System.out.println("unary_operator\t\t: '+'"); $op = "+"; }
	|   '-' { if (TRACEON) System.out.println("unary_operator\t\t: '-'"); $op = "-"; }
	|   '~' { if (TRACEON) System.out.println("unary_operator\t\t: '~'"); $op = "~"; }
	|   '!' { if (TRACEON) System.out.println("unary_operator\t\t: '!'"); $op = "!"; }
	;

/* Fragment */
fragment LETTER     : 'a'..'z' | 'A'..'Z' | '_' | '$';
fragment DIGIT  : '0'..'9';
fragment OCT_DIGIT  : '0'..'7';
fragment HEX_DIGIT  : '0'..'9' | 'a'..'f' | 'A'..'F';
fragment EXPONENT   : ('e'|'E') ('+'|'-')? (DIGIT)+;
fragment INT_SUF    : ('u'|'U')? ('l'|'L')?;
fragment FLOAT_SUF  : 'f'|'F'|'d'|'D';
fragment FLOAT_NUM1 : (DIGIT)+'.'(DIGIT)*;
fragment FLOAT_NUM2 : '.'(DIGIT)+;
fragment FLOAT_NUM3 : (DIGIT)+;

/* Value */
ID          : (LETTER)(LETTER | DIGIT)*;
DEC_NUM     : ('0' | '1'..'9' DIGIT*) INT_SUF;
OCT_NUM     : '0' (OCT_DIGIT)+ INT_SUF;
HEX_NUM     : '0' ('x' | 'X') HEX_DIGIT+ INT_SUF;
FLOAT_NUM   : (FLOAT_NUM1 | FLOAT_NUM2) EXPONENT? FLOAT_SUF? 
            | FLOAT_NUM3 (EXPONENT | EXPONENT? FLOAT_SUF);
CHAR_VAL    : '\'' '\\'? (.) '\'';
LITERAL     : '"' (('\\' (.)) | ~('\\' | '"'))* '"';

/* Skip */
WS          : ( ' ' | '\t' | '\r' | '\n' )             {$channel=HIDDEN;};
COMMENT1    : '//'(.)*'\n'                             {$channel=HIDDEN;};
COMMENT2    : '/*' (options{greedy=false;}: .)* '*/'   {$channel=HIDDEN;};
LINE_COMMAND: '#' ~('\n'|'\r')* '\r'? '\n'             {$channel=HIDDEN;};
