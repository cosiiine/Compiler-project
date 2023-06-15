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
    List<String> TextCode = new ArrayList<String>();
    String place = "";

    public enum Type {
        // Const_Int,
        Void,
        Char,
        String,
        Short,
        Int,
        Long,
        Float,
        Signed,
        Unsigned,
        Bool,
        Unknown,
        NoExist,
        Error
    }
	class tVar {
		int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
		int   iValue;   // value of constant integer. Ex: 123.
		float fValue;   // value of constant floating point. Ex: 2.314.
        String cValue;  // value of constant string or char.
	};
	class Info {
		Type theType;
		tVar theVar;
		Info() {
            theType = Type.Error;
            theVar = new tVar();
		}
	};
    String newLabel() {
		labelCount ++;
		return (new String("L")) + Integer.toString(labelCount);
    }
    public List<String> getTextCode() {
       	return TextCode;
    }
	void prologue() {
		TextCode.add("; === prologue ====");
		TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
		TextCode.add("define dso_local i32 @main()");
		TextCode.add("{");
	}
    void epilogue() {
		/* handle epilogue */
		TextCode.add("\n; === epilogue ===");
		TextCode.add("ret i32 0");
		TextCode.add("}");
    }
	
	class Env { // HashMap<String, Info> symtab = new HashMap<String, Info>();
		private HashMap<String, Info> table;
		protected Env prev;

		public Env(Env p) {
			table = new HashMap<String, Info>();
			prev = p;
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
    Env top = new Env(null), saved;
    void declare(String text, Type type, int line) {
        if (top.table.get(text) != null) System.out.println("Error! " + line + ": Redeclared identifier.");
        else {
            Info theEntry = new Info();
            theEntry.theType = type;
            theEntry.theVar.varIndex = varCount++;
            top.put(text, theEntry);
        }
    }
}

/* Start */
program
    :   external_declaration+
        {
			if (TRACEON) System.out.println("program\t\t\t: external_declaration+");
			if (!MAIN) System.out.println("Error!: Undefined reference to 'main'.");
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
    :   ID  { declare($ID.text, $attr_type, $ID.getLine()); }
        ('=' initializer
            {
                if ($attr_type != $initializer.theInfo.theType) {
                    System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the operator = in a declaration.");
                } else {
                    Info theEntry = $initializer.theInfo;
                    top.put($ID.text, theEntry);
                }
            }
        )?
        { if (TRACEON) System.out.println("init_declarator\t\t: ID ('=' initializer)?"); }
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
    :   type ID
        {
            saved = top;
            top = new Env(top);
            place = $ID.text;
            if (place.equals("main")) MAIN = true;
            declare($ID.text, $type.attr_type, $ID.getLine());
		} '(' parameter_list ')' '{' ( compound )* '}'
		{	
            top = saved;
            place = "";
			if (TRACEON) System.out.println("function_definition\t: type ID '(' parameter_type_list ')' '{' ( compound )* '}'");
		}
    ;
parameter_list
	:   parameter_declaration (',' parameter_declaration )*
        { if (TRACEON) System.out.println("parameter_list\t\t: parameter_declaration (',' parameter_declaration)*"); }
	|	
	;
parameter_declaration
	:   type ID
        {	
			if (TRACEON) System.out.println("parameter_declaration\t: type ID");
			declare($ID.text, $type.attr_type, $ID.getLine());
		}
	;
/* Statements */
statement
    :   compound_statement
        { if (TRACEON) System.out.println("statement\t\t: compound_statement"); }
    |   expression_statement
        { if (TRACEON) System.out.println("statement\t\t: expression_statement"); }
    |   if_statement
        { if (TRACEON) System.out.println("statement\t\t: if_statement"); }
    |   while_statement
        { if (TRACEON) System.out.println("statement\t\t: while_statement"); }
    |   for_statement
        { if (TRACEON) System.out.println("statement\t\t: for_statement"); }
    |   switch_statement
        { if (TRACEON) System.out.println("statement\t\t: switch_statement"); }
    |   jump_statement
        { if (TRACEON) System.out.println("statement\t\t: jump_statement"); }
    |   printf_statement
        { if (TRACEON) System.out.println("statement\t\t: printf_statement"); }
    |	';'
        { if (TRACEON) System.out.println("statement\t\t: ';'"); }
    ;
compound_statement
    :   '{' { saved = top; }
        ( compound )* 
        '}' { top = saved; }
        { if (TRACEON) System.out.println("compound_statement\t: '{' ( declaration | statement )* '}'"); }
    ;
compound
	:	declaration | statement
	;
expression_statement
    :   expression ';'
        { if (TRACEON) System.out.println("expression_statement\t: expression ';'"); }
    ;
if_statement
    :   'if' '(' expression ')' statement (('else') => else_statement)?
        {
			if (TRACEON) System.out.println("if_statement\t\t: if ( expression ) statement");
			
			if ($expression.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $if_statement.start.getLine() + ": Type mismatch in a if_statement's condition.");
			}
		}
    ;
else_statement
    :   'else' statement
        { if (TRACEON) System.out.println("else_statement\t\t: else statement"); }
    ;
while_statement
    :   'do' statement 'while' '(' expression ')' ';'
        {
			if (TRACEON) System.out.println("while_statement\t\t: do statement while ( expression ) ;");
			
			if ($expression.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			}
		}
    |   'while' '(' expression ')' statement
        {
			if (TRACEON) System.out.println("while_statement\t\t: while ( expression ) statement");
			
			if ($expression.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			}
		}
    ;
for_statement
    :   'for' '(' expression_statement a = expression ';' expression? ')' statement
        {
			if (TRACEON) System.out.println("for_statement\t\t: 'for' '(' expression_statement expression ';' expression? ')' statement");
			
			if ($a.theInfo.theType != Type.Bool) {
				System.out.println("Error! " + $for_statement.start.getLine() + ": Type mismatch in a for_statement's condition.");
			}
		}
    ;
switch_statement
    :   'switch' '(' expression ')' '{' (labeled_statement[$expression.theInfo.theType])* '}'
        { if (TRACEON) System.out.println("switch_statement\t: switch ( expression ) { labeled_statement* }"); }
    ;
labeled_statement
[Type attr_type]
	:   'case' conditional_expression ':' statement*
        {
			if (TRACEON) System.out.println("labeled_statement\t: 'case' conditional_expression ':' statement*");
			
			if ($conditional_expression.theInfo.theType != $attr_type) {
				System.out.println("Error! " + $labeled_statement.start.getLine() + ": Type mismatch in a labeled_statement.");
			}
		}
	|   'default' ':' statement*
        { if (TRACEON) System.out.println("labeled_statement\t: 'default' ':' statement*"); }
	;
jump_statement
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
			}
		}
	|	'return' ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: 'return' ';'");

			if (top.get(place).theType != Type.Void) {
				System.out.println("Error! " + $jump_statement.start.getLine() + ": Return wrong type.");
			}
		}
	;
printf_statement
    :   'printf' '(' LITERAL 
		(	',' ID
			{
				if (top.get($ID.text) == null) {
					System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
				}
			}
		)* ')' ';'
        { if (TRACEON) System.out.println("printf_statement\t: printf ( LITERAL (, ID)* );"); }
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
	:   ID assignment_operator a = assignment_expression
        {
			if (TRACEON) System.out.println("assignment_expression\t: ID assignment_operator assignment_expression");
			
			if (top.get($ID.text) == null) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
                $theInfo = new Info();
			} else {
				if (top.get($ID.text).theType != $a.theInfo.theType) {
					System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the two sides of an assignment.");
                    $theInfo = new Info();
				} else if ($assignment_operator.op == "\%=" && ($a.theInfo.theType != Type.Int || top.get($ID.text).theType != Type.Int)) {
					System.out.println("Error! " + $a.start.getLine() + ": The operand type of operator \%= is not an integer.");
                    $theInfo = new Info();
				} else { $theInfo = top.get($ID.text); }
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
		('?' a = conditional_expression ':' b = conditional_expression
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
				}
			}
		)*
        { if (TRACEON) System.out.println("and_expression\t\t: equality_expression ('&' equality_expression)*"); }
	;
equality_expression
returns [Info theInfo]
	:   a = relational_expression { $theInfo = $a.theInfo; }
		(	equality_operator b = relational_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $equality_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
					$theInfo.theType = Type.Bool;
				}
			}
		)*
		{ if (TRACEON) System.out.println("equality_expression\t: relational_expression (equality_operator relational_expression)*"); }
	;
relational_expression
returns [Info theInfo]
	:   a = shift_expression { $theInfo = $a.theInfo; }
		(	relational_operator b = shift_expression
			{ 
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $relational_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else {
					$theInfo.theType = Type.Bool;
				}
			}
		)*
        { if (TRACEON) System.out.println("relational_expression\t: shift_expression (relational_operator shift_expression)*"); }
	;
shift_expression
returns [Info theInfo]
    :   a = add_expression { $theInfo = $a.theInfo; }
		(	shift_operator b = add_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $shift_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				}
			}
		)* 
        { if (TRACEON) System.out.println("shift_expression\t\t: add_expression (shift_operator add_expression)* "); }
    ;
add_expression
returns [Info theInfo]
    :   a = mult_expression { $theInfo = $a.theInfo; }
		(	add_operator b = mult_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $add_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				}
			}
		)* 
        { if (TRACEON) System.out.println("add_expression\t\t: mult_expression (add_operator mult_expression)* "); }
    ;
mult_expression
returns [Info theInfo]
    :   a = cast_expression { $theInfo = $a.theInfo; }
		(	mult_operator b = cast_expression
			{
				if ($a.theInfo.theType != $b.theInfo.theType) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $mult_operator.op + " in an expression.");
					$theInfo.theType = Type.Error;
				} else if ($mult_operator.op == "\%" && $a.theInfo.theType != Type.Int) {
					System.out.println("Error! " + $a.start.getLine() + ": The operand type of operator \% is not an integer.");
					$theInfo.theType = Type.Error;
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
            $theInfo = $a.theInfo;
            $theInfo.theType = $type.attr_type;
        }
    |   unary_expression
        {
            if (TRACEON) System.out.println("cast_expression\t\t: '(' type ')' cast_expression");
            $theInfo = $unary_expression.theInfo;
        }
    ;
unary_expression
returns [Info theInfo]
@init { theInfo = new Info(); }
    :   postfix_expression
        { if (TRACEON) System.out.println("unary_expression\t: postfix_expression"); 	            $theInfo = $postfix_expression.theInfo;	}
	|   '++' a = unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: '++' unary_expression");             $theInfo = $a.theInfo;	}
	|   '--' b = unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: '--' unary_expression");             $theInfo = $b.theInfo;	}
	|   unary_operator cast_expression
        { if (TRACEON) System.out.println("unary_expression\t: unary_operator cast_expression");    $theInfo = $cast_expression.theInfo; }
	|   'sizeof' unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: 'sizeof' unary_expression");         $theInfo.theType = Type.Int; }
	|   'sizeof' '(' type ')'
        { if (TRACEON) System.out.println("unary_expression\t: 'sizeof' '(' type ')'"); 	        $theInfo.theType = Type.Int; }
	;

postfix_expression
returns [Info theInfo]
@init { theInfo = new Info(); }
	:   primary_expression { $theInfo.theType = Type.NoExist; }
        (   (	'[' expression ']'
			|   '(' ')'
			|   '(' expression ')'
			|   '++'
			|   '--'
			)
			{
				if ($theInfo.theType == Type.NoExist) {
					$theInfo = $primary_expression.theInfo;
				}
			}
		// |   ('.' | '->') ID
        )*
		{
			if (TRACEON) System.out.println("postfix_expression\t: primary_expression (('[' expression ']' | '(' ')' | '(' expression ')' | '++' | '--')*");

			if ($theInfo.theType == Type.NoExist) {
                $theInfo = $primary_expression.theInfo;
            }
		}
	;

primary_expression
returns [Info theInfo]
@init { theInfo = new Info(); }
    :   ID
        {
			if (TRACEON) System.out.println("primary_expression\t: ID");

			if (top.get($ID.text) == null) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
			}  else {
				$theInfo = top.get($ID.text);
			}
		}
    |   constant
        { if (TRACEON) System.out.println("primary_expression\t: constant"); 			$theInfo = $constant.theInfo; 	}
    |   '(' expression ')'
        { if (TRACEON) System.out.println("primary_expression\t: '(' expression ')'"); 	$theInfo = $expression.theInfo; }
    ;

/* Definition */
type 				returns [Type attr_type]
    :   'void'      { if (TRACEON) System.out.println("type\t\t\t: 'void'");	$attr_type = Type.Void;	}
	|   'char'      { if (TRACEON) System.out.println("type\t\t\t: 'char'");	$attr_type = Type.Char;	}
	|   'short'     { if (TRACEON) System.out.println("type\t\t\t: 'short'");	$attr_type = Type.Short;}
	|   'int'       { if (TRACEON) System.out.println("type\t\t\t: 'int'");		$attr_type = Type.Int;	}
	|   'long'      { if (TRACEON) System.out.println("type\t\t\t: 'long'");	$attr_type = Type.Long;	}
	|   'float'     { if (TRACEON) System.out.println("type\t\t\t: 'float'");	$attr_type = Type.Float;}
	|   'double'    { if (TRACEON) System.out.println("type\t\t\t: 'double'");	$attr_type = Type.Float;}
	|   'signed'    { if (TRACEON) System.out.println("type\t\t\t: 'signed' ");	$attr_type = Type.Signed;	}
	|   'unsigned'  { if (TRACEON) System.out.println("type\t\t\t: 'unsigned'");$attr_type = Type.Unsigned;	}
    ;

constant
returns [Info theInfo]
@init { theInfo = new Info(); }
    :   DEC_NUM     { if (TRACEON) System.out.println("constant\t\t: DEC_NUM");		$theInfo.theType = Type.Int;    $theInfo.theVar.iValue = Integer.parseInt($DEC_NUM.text); }
    |   OCT_NUM     { if (TRACEON) System.out.println("constant\t\t: OCT_NUM");		$theInfo.theType = Type.Int;    $theInfo.theVar.cValue = $OCT_NUM.text;  }
    |   HEX_NUM     { if (TRACEON) System.out.println("constant\t\t: HEX_NUM"); 	$theInfo.theType = Type.Int;    $theInfo.theVar.cValue = $HEX_NUM.text;  }
    |   FLOAT_NUM   { if (TRACEON) System.out.println("constant\t\t: FLOAT_NUM");	$theInfo.theType = Type.Float;  $theInfo.theVar.fValue = Float.parseFloat($FLOAT_NUM.text); }
    |   CHAR_VAL    { if (TRACEON) System.out.println("constant\t\t: CHAR_VAL");	$theInfo.theType = Type.Char;   $theInfo.theVar.cValue = $CHAR_VAL.text; }
    |   LITERAL     { if (TRACEON) System.out.println("constant\t\t: LITERAL ");	$theInfo.theType = Type.String; $theInfo.theVar.cValue = $LITERAL.text;  }
    ;

assignment_operator	returns [String op]
	:   '='     { if (TRACEON) System.out.println("assignment_operator\t: '='");	$op = "=";	}
	|   '*='    { if (TRACEON) System.out.println("assignment_operator\t: '*='");	$op = "*=";	}
	|   '/='    { if (TRACEON) System.out.println("assignment_operator\t: '/='");	$op = "/=";	}
	|   '%='    { if (TRACEON) System.out.println("assignment_operator\t: '\%='");	$op = "\%=";}
	|   '+='    { if (TRACEON) System.out.println("assignment_operator\t: '+='");	$op = "+=";	}
	|   '-='    { if (TRACEON) System.out.println("assignment_operator\t: '-='");	$op = "-=";	}
	|   '<<='   { if (TRACEON) System.out.println("assignment_operator\t: '<<='");	$op = "<<=";}
	|   '>>='   { if (TRACEON) System.out.println("assignment_operator\t: '>>='");	$op = ">>=";}
	|   '&='    { if (TRACEON) System.out.println("assignment_operator\t: '&='");	$op = "&=";	}
	|   '^='    { if (TRACEON) System.out.println("assignment_operator\t: '^='");	$op = "^=";	}
	|   '|='    { if (TRACEON) System.out.println("assignment_operator\t: '|='");	$op = "|=";	}
	;

equality_operator	returns [String op]
	:	'==' 	{ if (TRACEON) System.out.println("equality_operator\t: '=='");	$op = "==";	}
	| 	'!='	{ if (TRACEON) System.out.println("equality_operator\t: '!='");	$op = "!=";	}
	;

relational_operator	returns [String op]
	:	'>' 	{ if (TRACEON) System.out.println("relational_operator\t: '>'");$op = ">";	}
	| 	'<' 	{ if (TRACEON) System.out.println("relational_operator\t: '<'");$op = "<";	}
	| 	'>=' 	{ if (TRACEON) System.out.println("relational_operator\t: '>='");$op = ">=";}
	| 	'<=' 	{ if (TRACEON) System.out.println("relational_operator\t: '<='");$op = "<=";}
	;

shift_operator 		returns [String op]
	:	'>>' 	{ if (TRACEON) System.out.println("shift_operator\t: '>>'");	$op = ">>";}
	|	'<<' 	{ if (TRACEON) System.out.println("shift_operator\t: '<<'");	$op = "<<";}
	;
	
add_operator 		returns [String op]
	:	'+'		{ if (TRACEON) System.out.println("add_operator\t: '+'");	$op = "+";	}
	|	'-'		{ if (TRACEON) System.out.println("add_operator\t: '-'");	$op = "-";	}
	;

mult_operator 		returns [String op]
	:	'*'		{ if (TRACEON) System.out.println("mult_operator\t: '*'");	$op = "*";	}
	|	'/'		{ if (TRACEON) System.out.println("mult_operator\t: '/'");	$op = "/";	}
	|	'%'		{ if (TRACEON) System.out.println("mult_operator\t: '\%'");	$op = "\%";	}
	;

unary_operator
	:   '&' { if (TRACEON) System.out.println("unary_operator\t\t: '&'"); }
	|   '*' { if (TRACEON) System.out.println("unary_operator\t\t: '*'"); }
	|   '+' { if (TRACEON) System.out.println("unary_operator\t\t: '+'"); }
	|   '-' { if (TRACEON) System.out.println("unary_operator\t\t: '-'"); }
	|   '~' { if (TRACEON) System.out.println("unary_operator\t\t: '~'"); }
	|   '!' { if (TRACEON) System.out.println("unary_operator\t\t: '!'"); }
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
