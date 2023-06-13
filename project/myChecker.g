grammar myChecker;
options {
    language = Java;
}
@header {
    // import packages here.
    import java.util.HashMap;
}
@members {
    boolean TRACEON = false;
	String inner = "";
    HashMap<String, Type> global = new HashMap<String, Type>();
	HashMap<String, Type> local = new HashMap<String, Type>();

    public enum Type {
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
}

/* Start */
program
    :   external_declaration+
        {
			if (TRACEON) System.out.println("program\t\t\t: external_declaration+");
			if (!global.containsKey("main")) System.out.println("Error!: Undefined reference to 'main'.");
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

init_declarator_list 	[Type attr_type]
    :   init_declarator [$attr_type] (',' init_declarator[$attr_type])*
        { if (TRACEON) System.out.println("init_declarator_list\t: init_declarator (',' init_declarator)*"); }
    ;

init_declarator 		[Type attr_type]
    :   ID 
		(	'=' initializer
			{
				if ($attr_type != $initializer.attr_type) {
					System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the operator = in a declaration.");
				}
			}
		)?
        {
			if (TRACEON) System.out.println("init_declarator\t\t: ID ('=' initializer)?");
			
			if (inner.isEmpty()) {
				if (global.containsKey($ID.text)) System.out.println("Error! " + $ID.getLine() + ": Redeclared identifier.");
				else global.put($ID.text, $attr_type);
			} else {
				if (local.containsKey($ID.text)) System.out.println("Error! " + $ID.getLine() + ": Redeclared identifier.");
				else local.put($ID.text, $attr_type);
			}
		}
    ;

initializer 	returns [Type attr_type]
    :   assignment_expression                       
        {
			if (TRACEON) System.out.println("initializer\t\t: assignment_expression");
			$attr_type = $assignment_expression.attr_type;
		}
	;

/* Function */
function_definition
    :   type ID
        {
			inner = $ID.text;
			if (global.containsKey($ID.text)) {
				System.out.println("Error! " + $ID.getLine() + ": Redeclared identifier.");
			} else {
				global.put($ID.text, $type.attr_type);
			}
		} '(' parameter_list ')' compound_statement
		{	
			if (TRACEON) System.out.println("function_definition\t: type ID '(' parameter_type_list ')' compound_statement");
			local.clear();
			inner = "";
		}
    ;

parameter_list
	:   a = parameter_declaration 			{ local.put($a.text, $a.attr_type); }
		(	',' b = parameter_declaration 	{ local.put($b.text, $b.attr_type); } )*
        { if (TRACEON) System.out.println("parameter_list\t\t: parameter_declaration (',' parameter_declaration)*"); }
	|	
	;

parameter_declaration	returns [Type attr_type, String text]
	:   type ID
        {	
			if (TRACEON) System.out.println("parameter_declaration\t: type ID");
			$attr_type = $type.attr_type; $text = $ID.text;
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
    :   '{' ( compound )* '}'
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
			
			if ($expression.attr_type != Type.Bool) {
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
			
			if ($expression.attr_type != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			}
		}
    |   'while' '(' expression ')' statement
        {
			if (TRACEON) System.out.println("while_statement\t\t: while ( expression ) statement");
			
			if ($expression.attr_type != Type.Bool) {
				System.out.println("Error! " + $while_statement.start.getLine() + ": Type mismatch in a while_statement's condition.");
			}
		}
    ;

for_statement
    :   'for' '(' expression_statement a = expression ';' expression? ')' statement
        {
			if (TRACEON) System.out.println("for_statement\t\t: 'for' '(' expression_statement expression ';' expression? ')' statement");
			
			if ($a.attr_type != Type.Bool) {
				System.out.println("Error! " + $for_statement.start.getLine() + ": Type mismatch in a for_statement's condition.");
			}
		}
    ;

switch_statement
    :   'switch' '(' expression ')' '{' (labeled_statement[$expression.attr_type])* '}'
        { if (TRACEON) System.out.println("switch_statement\t: switch ( expression ) { labeled_statement* }"); }
    ;

labeled_statement [Type attr_type]
	:   'case' conditional_expression ':' statement*
        {
			if (TRACEON) System.out.println("labeled_statement\t: 'case' conditional_expression ':' statement*");
			
			if ($conditional_expression.attr_type != $attr_type) {
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
			
			if (!global.containsKey($ID.text) && !local.containsKey($ID.text)) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
			}
		}
	|   'continue' ';'          { if (TRACEON) System.out.println("jump_statement\t\t: continue;"); }
	|   'break' ';'             { if (TRACEON) System.out.println("jump_statement\t\t: break;"); }
	|   'return' expression ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: 'return' expression ';'");
			
			if (global.get(inner) == Type.Void) {
				System.out.println("Error! " + $expression.start.getLine() + ": Return wrong type.");
			} else if (global.get(inner) != $expression.attr_type) {
				System.out.println("Error! " + $expression.start.getLine() + ": Return wrong type.");
			}
		}
	|	'return' ';'
		{
			if (TRACEON) System.out.println("jump_statement\t\t: 'return' ';'");

			if (global.get(inner) != Type.Void) {
				System.out.println("Error! " + $jump_statement.start.getLine() + ": Return wrong type.");
			}
		}
	;

printf_statement
    :   'printf' '(' LITERAL 
		(	',' ID
			{
				if (!global.containsKey($ID.text) && !local.containsKey($ID.text)) {
					System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
				}
			}
		)* ')' ';'
        { if (TRACEON) System.out.println("printf_statement\t: printf ( LITERAL (, ID)* );"); }
    ;

/* Expression */
expression				returns [Type attr_type]
    :   a = assignment_expression { $attr_type = $a.attr_type; } 
		(	',' b = assignment_expression 
			{ $attr_type = $b.attr_type; }
		)*
        { if (TRACEON) System.out.println("expression\t\t: assignment_expression (',' assignment_expression)*"); }
    ;

assignment_expression 	returns [Type attr_type]
	:   ID assignment_operator a = assignment_expression
        {
			if (TRACEON) System.out.println("assignment_expression\t: ID assignment_operator assignment_expression");
			
			if (!global.containsKey($ID.text) && !local.containsKey($ID.text)) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
				$attr_type = Type.Error;
			} else if (local.containsKey($ID.text)) {
				if (local.get($ID.text) != $a.attr_type) {
					System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the two sides of an assignment.");
					$attr_type = Type.Error;
				} else if ($assignment_operator.op == "\%=" && $a.attr_type != Type.Int) {
					System.out.println("Error! " + $a.start.getLine() + ": The operand type of operator \%= is not an integer.");
					$attr_type = Type.Error;
				} else { $attr_type = local.get($ID.text); }
			} else {
				if (global.get($ID.text) != $a.attr_type) {
					System.out.println("Error! " + $ID.getLine() + ": Type mismatch for the two sides of an assignment.");
					$attr_type = Type.Error;
				} else if ($assignment_operator.op == "\%=" && $a.attr_type != Type.Int) {
					System.out.println("Error! " + $a.start.getLine() + ": The operand type of operator \%= is not an integer.");
					$attr_type = Type.Error;
				} else { $attr_type = global.get($ID.text); }
			}
		}
	|   conditional_expression
        {
			if (TRACEON) System.out.println("assignment_expression\t: conditional_expression");

			$attr_type = $conditional_expression.attr_type;
		}
	;

conditional_expression 	returns [Type attr_type]
	: 	logical_or_expression { $attr_type = $logical_or_expression.attr_type; }
		('?' a = conditional_expression ':' b = conditional_expression
			{
				if ($attr_type != Type.Bool || $a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $logical_or_expression.start.getLine() + ": Type mismatch for the operator ? : in an expression.");
					$attr_type = Type.Error;
				}  else {
					$attr_type = $a.attr_type;
				}
			}
		)?
        { if (TRACEON) System.out.println("conditional_expression\t: logical_or_expression ('?' conditional_expression ':' conditional_expression)?"); }
	;

logical_or_expression 	returns [Type attr_type]
	:   a = logical_and_expression { $attr_type = $a.attr_type; }
		(	'||' b = logical_and_expression
			{
				if ($attr_type != Type.Bool || $b.attr_type != Type.Bool) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator || in an expression.");
					$attr_type = Type.Error;
				}
			}
		)*
        { if (TRACEON) System.out.println("conditional_expression\t: logical_and_expression ('||' logical_and_expression)*"); }
	;

logical_and_expression 	returns [Type attr_type]
	:   a = inclusive_or_expression { $attr_type = $a.attr_type; }
		(	'&&' b = inclusive_or_expression
			{
				if ($attr_type != Type.Bool || $b.attr_type != Type.Bool) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator && in an expression.");
					$attr_type = Type.Error;
				}
			}
		)*
        { if (TRACEON) System.out.println("logical_and_expression\t: inclusive_or_expression ('&&' inclusive_or_expression)*"); }
	;

inclusive_or_expression returns [Type attr_type]
	:   a = exclusive_or_expression { $attr_type = $a.attr_type; }
		(	'|' b = exclusive_or_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator | in an expression.");
					$attr_type = Type.Error;
				}
			}
		)*
        { if (TRACEON) System.out.println("inclusive_or_expression\t: exclusive_or_expression ('|' exclusive_or_expression)*"); }
	;

exclusive_or_expression returns [Type attr_type]
	:   a = and_expression { $attr_type = $a.attr_type; }
		(	'^' b = and_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator ^ in an expression.");
					$attr_type = Type.Error;
				}
			}
		)*
        { if (TRACEON) System.out.println("exclusive_or_expression\t: and_expression ('^' and_expression)*"); }
	;

and_expression 			returns [Type attr_type]
	:   a = equality_expression { $attr_type = $a.attr_type; }
		(	'&' b = equality_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator & in an expression.");
					$attr_type = Type.Error;
				}
			}
		)*
        { if (TRACEON) System.out.println("and_expression\t\t: equality_expression ('&' equality_expression)*"); }
	;

equality_expression 	returns [Type attr_type]
	:   a = relational_expression { $attr_type = $a.attr_type; }
		(	equality_operator b = relational_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $equality_operator.op + " in an expression.");
					$attr_type = Type.Error;
				} else {
					$attr_type = Type.Bool;
				}
			}
		)*
		{ if (TRACEON) System.out.println("equality_expression\t: relational_expression (equality_operator relational_expression)*"); }
	;

relational_expression 	returns [Type attr_type]
	:   a = shift_expression { $attr_type = $a.attr_type; }
		(	relational_operator b = shift_expression
			{ 
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $relational_operator.op + " in an expression.");
					$attr_type = Type.Error;
				} else {
					$attr_type = Type.Bool;
				}
			}
		)*
        { if (TRACEON) System.out.println("relational_expression\t: shift_expression (relational_operator shift_expression)*"); }
	;

shift_expression 		returns [Type attr_type]
    :   a = add_expression { $attr_type = $a.attr_type; }
		(	shift_operator b = add_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $shift_operator.op + " in an expression.");
					$attr_type = Type.Error;
				}
			}
		)* 
        { if (TRACEON) System.out.println("shift_expression\t\t: add_expression (shift_operator add_expression)* "); }
    ;

add_expression 			returns [Type attr_type]
    :   a = mult_expression { $attr_type = $a.attr_type; }
		(	add_operator b = mult_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $add_operator.op + " in an expression.");
					$attr_type = Type.Error;
				}
			}
		)* 
        { if (TRACEON) System.out.println("add_expression\t\t: mult_expression (add_operator mult_expression)* "); }
    ;

mult_expression 		returns [Type attr_type]
    :   a = cast_expression { $attr_type = $a.attr_type; }
		(	mult_operator b = cast_expression
			{
				if ($a.attr_type != $b.attr_type) {
					System.out.println("Error! " + $a.start.getLine() + ": Type mismatch for the operator " + $mult_operator.op + " in an expression.");
					$attr_type = Type.Error;
				} else if ($mult_operator.op == "\%" && $a.attr_type != Type.Int) {
					System.out.println("Error! " + $a.start.getLine() + ": The operand type of operator \% is not an integer.");
					$attr_type = Type.Error;
				}
			}
		)* 
        { if (TRACEON) System.out.println("mult_expression\t\t: cast_expression (mult_operator cast_expression)* "); }
    ;

cast_expression 		returns [Type attr_type]
    :   '(' type ')' cast_expression
        { if (TRACEON) System.out.println("cast_expression\t\t: '(' type ')' cast_expression"); $attr_type = $type.attr_type; }
    |   unary_expression
        { if (TRACEON) System.out.println("cast_expression\t\t: '(' type ')' cast_expression"); $attr_type = $unary_expression.attr_type; }
    ;

unary_expression 		returns [Type attr_type]
    :   postfix_expression
        { if (TRACEON) System.out.println("unary_expression\t: postfix_expression"); 	$attr_type = $postfix_expression.attr_type;	}
	|   '++' a = unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: '++' unary_expression"); $attr_type = $a.attr_type;	}
	|   '--' b = unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: '--' unary_expression"); $attr_type = $b.attr_type;	}
	|   unary_operator cast_expression
        { if (TRACEON) System.out.println("unary_expression\t: unary_operator cast_expression"); $attr_type = $cast_expression.attr_type;}
	|   'sizeof' unary_expression
        { if (TRACEON) System.out.println("unary_expression\t: 'sizeof' unary_expression"); $attr_type = Type.Int;	}
	|   'sizeof' '(' type ')'
        { if (TRACEON) System.out.println("unary_expression\t: 'sizeof' '(' type ')'"); 	$attr_type = Type.Int;	}
	;

postfix_expression 		returns [Type attr_type]
	:   primary_expression { $attr_type = Type.NoExist; }
        (   (	'[' expression ']'
			|   '(' ')'
			|   '(' expression ')'
			|   '++'
			|   '--'
			)
			{
				if ($attr_type == Type.NoExist) {
					$attr_type = $primary_expression.attr_type;
				}
			}
		// |   ('.' | '->') ID
        )*
		{
			if (TRACEON) System.out.println("postfix_expression\t: primary_expression (('[' expression ']' | '(' ')' | '(' expression ')' | '++' | '--')*");

			if ($attr_type == Type.NoExist) {
				$attr_type = $primary_expression.attr_type;
			}
		}
	;

primary_expression 		returns [Type attr_type]
    :   ID
        {
			if (TRACEON) System.out.println("primary_expression\t: ID");

			if (!global.containsKey($ID.text) && !local.containsKey($ID.text)) {
				System.out.println("Error! " + $ID.getLine() + ": Undeclared identifier.");
				$attr_type = Type.Error;
			} else if (local.containsKey($ID.text)) {
				$attr_type = local.get($ID.text);
			} else {
				$attr_type = global.get($ID.text);
			}
		}
    |   constant
        { if (TRACEON) System.out.println("primary_expression\t: constant"); 			$attr_type = $constant.attr_type; 	}
    |   '(' expression ')'
        { if (TRACEON) System.out.println("primary_expression\t: '(' expression ')'"); 	$attr_type = $expression.attr_type; }
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

constant 			returns [Type attr_type]
    :   DEC_NUM     { if (TRACEON) System.out.println("constant\t\t: DEC_NUM");		$attr_type = Type.Int; 	}
    |   OCT_NUM     { if (TRACEON) System.out.println("constant\t\t: OCT_NUM");		$attr_type = Type.Int; 	}
    |   HEX_NUM     { if (TRACEON) System.out.println("constant\t\t: HEX_NUM"); 	$attr_type = Type.Int; 	}
    |   FLOAT_NUM   { if (TRACEON) System.out.println("constant\t\t: FLOAT_NUM");	$attr_type = Type.Float;}
    |   CHAR_VAL    { if (TRACEON) System.out.println("constant\t\t: CHAR_VAL");	$attr_type = Type.Char; }
    |   LITERAL     { if (TRACEON) System.out.println("constant\t\t: LITERAL ");	$attr_type = Type.String; 	}
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
