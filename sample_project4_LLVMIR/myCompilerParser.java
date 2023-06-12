// $ANTLR 3.5.3 myCompiler.g 2023-05-23 20:39:38

    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;


import org.antlr.runtime.*;
import java.util.Stack;
import java.util.List;
import java.util.ArrayList;

@SuppressWarnings("all")
public class myCompilerParser extends Parser {
	public static final String[] tokenNames = new String[] {
		"<invalid>", "<EOR>", "<DOWN>", "<UP>", "CHAR", "COMMENT", "ELSE", "EscapeSequence", 
		"FLOAT", "FOR", "Floating_point_constant", "IF", "INT", "Identifier", 
		"Integer_constant", "MAIN", "RelationOP", "STRING_LITERAL", "VOID", "WS", 
		"'&'", "'('", "')'", "'*'", "'+'", "','", "'-'", "'/'", "';'", "'='", 
		"'{'", "'}'"
	};
	public static final int EOF=-1;
	public static final int T__20=20;
	public static final int T__21=21;
	public static final int T__22=22;
	public static final int T__23=23;
	public static final int T__24=24;
	public static final int T__25=25;
	public static final int T__26=26;
	public static final int T__27=27;
	public static final int T__28=28;
	public static final int T__29=29;
	public static final int T__30=30;
	public static final int T__31=31;
	public static final int CHAR=4;
	public static final int COMMENT=5;
	public static final int ELSE=6;
	public static final int EscapeSequence=7;
	public static final int FLOAT=8;
	public static final int FOR=9;
	public static final int Floating_point_constant=10;
	public static final int IF=11;
	public static final int INT=12;
	public static final int Identifier=13;
	public static final int Integer_constant=14;
	public static final int MAIN=15;
	public static final int RelationOP=16;
	public static final int STRING_LITERAL=17;
	public static final int VOID=18;
	public static final int WS=19;

	// delegates
	public Parser[] getDelegates() {
		return new Parser[] {};
	}

	// delegators


	public myCompilerParser(TokenStream input) {
		this(input, new RecognizerSharedState());
	}
	public myCompilerParser(TokenStream input, RecognizerSharedState state) {
		super(input, state);
	}

	@Override public String[] getTokenNames() { return myCompilerParser.tokenNames; }
	@Override public String getGrammarFileName() { return "myCompiler.g"; }


	    boolean TRACEON = false;

	    // Type information.
	    public enum Type{
	       ERR, BOOL, INT, FLOAT, CHAR, CONST_INT;
	    }

	    // This structure is used to record the information of a variable or a constant.
	    class tVar {
		   int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
		   int   iValue;   // value of constant integer. Ex: 123.
		   float fValue;   // value of constant floating point. Ex: 2.314.
		};

	    class Info {
	       Type theType;  // type information.
	       tVar theVar;
		   
		   Info() {
	          theType = Type.ERR;
			  theVar = new tVar();
		   }
	    };

		
	    // ============================================
	    // Create a symbol table.
		// ArrayList is easy to extend to add more info. into symbol table.
		//
		// The structure of symbol table:
		// <variable ID, [Type, [varIndex or iValue, or fValue]]>
		//    - type: the variable type   (please check "enum Type")
		//    - varIndex: the variable's index, ex: t1, t2, ...
		//    - iValue: value of integer constant.
		//    - fValue: value of floating-point constant.
	    // ============================================

	    HashMap<String, Info> symtab = new HashMap<String, Info>();

	    // labelCount is used to represent temporary label.
	    // The first index is 0.
	    int labelCount = 0;
		
	    // varCount is used to represent temporary variables.
	    // The first index is 0.
	    int varCount = 0;

	    // Record all assembly instructions.
	    List<String> TextCode = new ArrayList<String>();


	    /*
	     * Output prologue.
	     */
	    void prologue()
	    {
	       TextCode.add("; === prologue ====");
	       TextCode.add("declare dso_local i32 @printf(i8*, ...)\n");
		   TextCode.add("define dso_local i32 @main()");
		   TextCode.add("{");
	    }
	    
		
	    /*
	     * Output epilogue.
	     */
	    void epilogue()
	    {
	       /* handle epilogue */
	       TextCode.add("\n; === epilogue ===");
		   TextCode.add("ret i32 0");
	       TextCode.add("}");
	    }
	    
	    
	    /* Generate a new label */
	    String newLabel()
	    {
	       labelCount ++;
	       return (new String("L")) + Integer.toString(labelCount);
	    } 
	    
	    
	    public List<String> getTextCode()
	    {
	       return TextCode;
	    }



	// $ANTLR start "program"
	// myCompiler.g:103:1: program : VOID MAIN '(' ')' '{' declarations statements '}' ;
	public final void program() throws RecognitionException {
		try {
			// myCompiler.g:103:8: ( VOID MAIN '(' ')' '{' declarations statements '}' )
			// myCompiler.g:103:10: VOID MAIN '(' ')' '{' declarations statements '}'
			{
			match(input,VOID,FOLLOW_VOID_in_program36); 
			match(input,MAIN,FOLLOW_MAIN_in_program38); 
			match(input,21,FOLLOW_21_in_program40); 
			match(input,22,FOLLOW_22_in_program42); 

			           /* Output function prologue */
			           prologue();
			        
			match(input,30,FOLLOW_30_in_program63); 
			pushFollow(FOLLOW_declarations_in_program77);
			declarations();
			state._fsp--;

			pushFollow(FOLLOW_statements_in_program90);
			statements();
			state._fsp--;

			match(input,31,FOLLOW_31_in_program100); 

				   if (TRACEON)
				      System.out.println("VOID MAIN () {declarations statements}");

			           /* output function epilogue */	  
			           epilogue();
			        
			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "program"



	// $ANTLR start "declarations"
	// myCompiler.g:123:1: declarations : ( type Identifier ';' declarations |);
	public final void declarations() throws RecognitionException {
		Token Identifier1=null;
		Type type2 =null;

		try {
			// myCompiler.g:123:13: ( type Identifier ';' declarations |)
			int alt1=2;
			int LA1_0 = input.LA(1);
			if ( (LA1_0==CHAR||LA1_0==FLOAT||LA1_0==INT) ) {
				alt1=1;
			}
			else if ( (LA1_0==FOR||LA1_0==IF||LA1_0==Identifier||LA1_0==31) ) {
				alt1=2;
			}

			else {
				NoViableAltException nvae =
					new NoViableAltException("", 1, 0, input);
				throw nvae;
			}

			switch (alt1) {
				case 1 :
					// myCompiler.g:123:15: type Identifier ';' declarations
					{
					pushFollow(FOLLOW_type_in_declarations127);
					type2=type();
					state._fsp--;

					Identifier1=(Token)match(input,Identifier,FOLLOW_Identifier_in_declarations129); 
					match(input,28,FOLLOW_28_in_declarations131); 
					pushFollow(FOLLOW_declarations_in_declarations133);
					declarations();
					state._fsp--;


					           if (TRACEON)
					              System.out.println("declarations: type Identifier : declarations");

					           if (symtab.containsKey((Identifier1!=null?Identifier1.getText():null))) {
					              // variable re-declared.
					              System.out.println("Type Error: " + 
					                                  Identifier1.getLine() + 
					                                 ": Redeclared identifier.");
					              System.exit(0);
					           }
					                 
					           /* Add ID and its info into the symbol table. */
						       Info the_entry = new Info();
							   the_entry.theType = type2;
							   the_entry.theVar.varIndex = varCount;
							   varCount ++;
							   symtab.put((Identifier1!=null?Identifier1.getText():null), the_entry);

					           // issue the instruction.
							   // Ex: %a = alloca i32, align 4
					           if (type2 == Type.INT) { 
					              TextCode.add("%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
					           }
					        
					}
					break;
				case 2 :
					// myCompiler.g:150:9: 
					{

					           if (TRACEON)
					              System.out.println("declarations: ");
					        
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "declarations"



	// $ANTLR start "type"
	// myCompiler.g:157:1: type returns [Type attr_type] : ( INT | CHAR | FLOAT );
	public final Type type() throws RecognitionException {
		Type attr_type = null;


		try {
			// myCompiler.g:159:5: ( INT | CHAR | FLOAT )
			int alt2=3;
			switch ( input.LA(1) ) {
			case INT:
				{
				alt2=1;
				}
				break;
			case CHAR:
				{
				alt2=2;
				}
				break;
			case FLOAT:
				{
				alt2=3;
				}
				break;
			default:
				NoViableAltException nvae =
					new NoViableAltException("", 2, 0, input);
				throw nvae;
			}
			switch (alt2) {
				case 1 :
					// myCompiler.g:159:7: INT
					{
					match(input,INT,FOLLOW_INT_in_type190); 
					 if (TRACEON) System.out.println("type: INT"); attr_type =Type.INT; 
					}
					break;
				case 2 :
					// myCompiler.g:160:7: CHAR
					{
					match(input,CHAR,FOLLOW_CHAR_in_type200); 
					 if (TRACEON) System.out.println("type: CHAR"); attr_type =Type.CHAR; 
					}
					break;
				case 3 :
					// myCompiler.g:161:7: FLOAT
					{
					match(input,FLOAT,FOLLOW_FLOAT_in_type210); 
					if (TRACEON) System.out.println("type: FLOAT"); attr_type =Type.FLOAT; 
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
		return attr_type;
	}
	// $ANTLR end "type"



	// $ANTLR start "statements"
	// myCompiler.g:165:1: statements : ( statement statements |);
	public final void statements() throws RecognitionException {
		try {
			// myCompiler.g:165:11: ( statement statements |)
			int alt3=2;
			int LA3_0 = input.LA(1);
			if ( (LA3_0==FOR||LA3_0==IF||LA3_0==Identifier) ) {
				alt3=1;
			}
			else if ( (LA3_0==31) ) {
				alt3=2;
			}

			else {
				NoViableAltException nvae =
					new NoViableAltException("", 3, 0, input);
				throw nvae;
			}

			switch (alt3) {
				case 1 :
					// myCompiler.g:165:12: statement statements
					{
					pushFollow(FOLLOW_statement_in_statements221);
					statement();
					state._fsp--;

					pushFollow(FOLLOW_statements_in_statements223);
					statements();
					state._fsp--;

					}
					break;
				case 2 :
					// myCompiler.g:167:11: 
					{
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "statements"



	// $ANTLR start "statement"
	// myCompiler.g:170:1: statement : ( assign_stmt ';' | if_stmt | func_no_return_stmt ';' | for_stmt );
	public final void statement() throws RecognitionException {
		try {
			// myCompiler.g:170:10: ( assign_stmt ';' | if_stmt | func_no_return_stmt ';' | for_stmt )
			int alt4=4;
			switch ( input.LA(1) ) {
			case Identifier:
				{
				int LA4_1 = input.LA(2);
				if ( (LA4_1==29) ) {
					alt4=1;
				}
				else if ( (LA4_1==21) ) {
					alt4=3;
				}

				else {
					int nvaeMark = input.mark();
					try {
						input.consume();
						NoViableAltException nvae =
							new NoViableAltException("", 4, 1, input);
						throw nvae;
					} finally {
						input.rewind(nvaeMark);
					}
				}

				}
				break;
			case IF:
				{
				alt4=2;
				}
				break;
			case FOR:
				{
				alt4=4;
				}
				break;
			default:
				NoViableAltException nvae =
					new NoViableAltException("", 4, 0, input);
				throw nvae;
			}
			switch (alt4) {
				case 1 :
					// myCompiler.g:170:12: assign_stmt ';'
					{
					pushFollow(FOLLOW_assign_stmt_in_statement254);
					assign_stmt();
					state._fsp--;

					match(input,28,FOLLOW_28_in_statement256); 
					}
					break;
				case 2 :
					// myCompiler.g:171:12: if_stmt
					{
					pushFollow(FOLLOW_if_stmt_in_statement269);
					if_stmt();
					state._fsp--;

					}
					break;
				case 3 :
					// myCompiler.g:172:12: func_no_return_stmt ';'
					{
					pushFollow(FOLLOW_func_no_return_stmt_in_statement282);
					func_no_return_stmt();
					state._fsp--;

					match(input,28,FOLLOW_28_in_statement284); 
					}
					break;
				case 4 :
					// myCompiler.g:173:12: for_stmt
					{
					pushFollow(FOLLOW_for_stmt_in_statement297);
					for_stmt();
					state._fsp--;

					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "statement"



	// $ANTLR start "for_stmt"
	// myCompiler.g:176:1: for_stmt : FOR '(' assign_stmt ';' cond_expression ';' assign_stmt ')' block_stmt ;
	public final void for_stmt() throws RecognitionException {
		try {
			// myCompiler.g:176:9: ( FOR '(' assign_stmt ';' cond_expression ';' assign_stmt ')' block_stmt )
			// myCompiler.g:176:11: FOR '(' assign_stmt ';' cond_expression ';' assign_stmt ')' block_stmt
			{
			match(input,FOR,FOLLOW_FOR_in_for_stmt314); 
			match(input,21,FOLLOW_21_in_for_stmt316); 
			pushFollow(FOLLOW_assign_stmt_in_for_stmt318);
			assign_stmt();
			state._fsp--;

			match(input,28,FOLLOW_28_in_for_stmt320); 
			pushFollow(FOLLOW_cond_expression_in_for_stmt340);
			cond_expression();
			state._fsp--;

			match(input,28,FOLLOW_28_in_for_stmt342); 
			pushFollow(FOLLOW_assign_stmt_in_for_stmt362);
			assign_stmt();
			state._fsp--;

			match(input,22,FOLLOW_22_in_for_stmt378); 
			pushFollow(FOLLOW_block_stmt_in_for_stmt398);
			block_stmt();
			state._fsp--;

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "for_stmt"



	// $ANTLR start "if_stmt"
	// myCompiler.g:184:1: if_stmt : if_then_stmt if_else_stmt ;
	public final void if_stmt() throws RecognitionException {
		try {
			// myCompiler.g:185:13: ( if_then_stmt if_else_stmt )
			// myCompiler.g:185:15: if_then_stmt if_else_stmt
			{
			pushFollow(FOLLOW_if_then_stmt_in_if_stmt434);
			if_then_stmt();
			state._fsp--;

			pushFollow(FOLLOW_if_else_stmt_in_if_stmt436);
			if_else_stmt();
			state._fsp--;

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "if_stmt"



	// $ANTLR start "if_then_stmt"
	// myCompiler.g:189:1: if_then_stmt : IF '(' cond_expression ')' block_stmt ;
	public final void if_then_stmt() throws RecognitionException {
		try {
			// myCompiler.g:190:13: ( IF '(' cond_expression ')' block_stmt )
			// myCompiler.g:190:15: IF '(' cond_expression ')' block_stmt
			{
			match(input,IF,FOLLOW_IF_in_if_then_stmt474); 
			match(input,21,FOLLOW_21_in_if_then_stmt476); 
			pushFollow(FOLLOW_cond_expression_in_if_then_stmt478);
			cond_expression();
			state._fsp--;

			match(input,22,FOLLOW_22_in_if_then_stmt480); 
			pushFollow(FOLLOW_block_stmt_in_if_then_stmt482);
			block_stmt();
			state._fsp--;

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "if_then_stmt"



	// $ANTLR start "if_else_stmt"
	// myCompiler.g:194:1: if_else_stmt : ( ELSE block_stmt |);
	public final void if_else_stmt() throws RecognitionException {
		try {
			// myCompiler.g:195:13: ( ELSE block_stmt |)
			int alt5=2;
			int LA5_0 = input.LA(1);
			if ( (LA5_0==ELSE) ) {
				alt5=1;
			}
			else if ( (LA5_0==FOR||LA5_0==IF||LA5_0==Identifier||LA5_0==31) ) {
				alt5=2;
			}

			else {
				NoViableAltException nvae =
					new NoViableAltException("", 5, 0, input);
				throw nvae;
			}

			switch (alt5) {
				case 1 :
					// myCompiler.g:195:15: ELSE block_stmt
					{
					match(input,ELSE,FOLLOW_ELSE_in_if_else_stmt516); 
					pushFollow(FOLLOW_block_stmt_in_if_else_stmt518);
					block_stmt();
					state._fsp--;

					}
					break;
				case 2 :
					// myCompiler.g:197:13: 
					{
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "if_else_stmt"



	// $ANTLR start "block_stmt"
	// myCompiler.g:200:1: block_stmt : '{' statements '}' ;
	public final void block_stmt() throws RecognitionException {
		try {
			// myCompiler.g:200:11: ( '{' statements '}' )
			// myCompiler.g:200:13: '{' statements '}'
			{
			match(input,30,FOLLOW_30_in_block_stmt559); 
			pushFollow(FOLLOW_statements_in_block_stmt561);
			statements();
			state._fsp--;

			match(input,31,FOLLOW_31_in_block_stmt563); 
			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "block_stmt"



	// $ANTLR start "assign_stmt"
	// myCompiler.g:204:1: assign_stmt : Identifier '=' arith_expression ;
	public final void assign_stmt() throws RecognitionException {
		Token Identifier4=null;
		Info arith_expression3 =null;

		try {
			// myCompiler.g:204:12: ( Identifier '=' arith_expression )
			// myCompiler.g:204:14: Identifier '=' arith_expression
			{
			Identifier4=(Token)match(input,Identifier,FOLLOW_Identifier_in_assign_stmt575); 
			match(input,29,FOLLOW_29_in_assign_stmt577); 
			pushFollow(FOLLOW_arith_expression_in_assign_stmt579);
			arith_expression3=arith_expression();
			state._fsp--;


			                Info theRHS = arith_expression3;
							Info theLHS = symtab.get((Identifier4!=null?Identifier4.getText():null)); 
					   
			                if ((theLHS.theType == Type.INT) &&
			                    (theRHS.theType == Type.INT)) {		   
			                   // issue store insruction.
			                   // Ex: store i32 %tx, i32* %ty
			                   TextCode.add("store i32 %t" + theRHS.theVar.varIndex + ", i32* %t" + theLHS.theVar.varIndex);
							} else if ((theLHS.theType == Type.INT) &&
							    (theRHS.theType == Type.CONST_INT)) {
			                   // issue store insruction.
			                   // Ex: store i32 value, i32* %ty
			                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* %t" + theLHS.theVar.varIndex);				
							}
						 
			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "assign_stmt"



	// $ANTLR start "func_no_return_stmt"
	// myCompiler.g:224:1: func_no_return_stmt : Identifier '(' argument ')' ;
	public final void func_no_return_stmt() throws RecognitionException {
		try {
			// myCompiler.g:224:20: ( Identifier '(' argument ')' )
			// myCompiler.g:224:22: Identifier '(' argument ')'
			{
			match(input,Identifier,FOLLOW_Identifier_in_func_no_return_stmt621); 
			match(input,21,FOLLOW_21_in_func_no_return_stmt623); 
			pushFollow(FOLLOW_argument_in_func_no_return_stmt625);
			argument();
			state._fsp--;

			match(input,22,FOLLOW_22_in_func_no_return_stmt627); 
			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "func_no_return_stmt"



	// $ANTLR start "argument"
	// myCompiler.g:228:1: argument : arg ( ',' arg )* ;
	public final void argument() throws RecognitionException {
		try {
			// myCompiler.g:228:9: ( arg ( ',' arg )* )
			// myCompiler.g:228:11: arg ( ',' arg )*
			{
			pushFollow(FOLLOW_arg_in_argument655);
			arg();
			state._fsp--;

			// myCompiler.g:228:15: ( ',' arg )*
			loop6:
			while (true) {
				int alt6=2;
				int LA6_0 = input.LA(1);
				if ( (LA6_0==25) ) {
					alt6=1;
				}

				switch (alt6) {
				case 1 :
					// myCompiler.g:228:16: ',' arg
					{
					match(input,25,FOLLOW_25_in_argument658); 
					pushFollow(FOLLOW_arg_in_argument660);
					arg();
					state._fsp--;

					}
					break;

				default :
					break loop6;
				}
			}

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "argument"



	// $ANTLR start "arg"
	// myCompiler.g:231:1: arg : ( arith_expression | STRING_LITERAL );
	public final void arg() throws RecognitionException {
		try {
			// myCompiler.g:231:4: ( arith_expression | STRING_LITERAL )
			int alt7=2;
			int LA7_0 = input.LA(1);
			if ( (LA7_0==Floating_point_constant||(LA7_0 >= Identifier && LA7_0 <= Integer_constant)||(LA7_0 >= 20 && LA7_0 <= 21)||LA7_0==26) ) {
				alt7=1;
			}
			else if ( (LA7_0==STRING_LITERAL) ) {
				alt7=2;
			}

			else {
				NoViableAltException nvae =
					new NoViableAltException("", 7, 0, input);
				throw nvae;
			}

			switch (alt7) {
				case 1 :
					// myCompiler.g:231:6: arith_expression
					{
					pushFollow(FOLLOW_arith_expression_in_arg678);
					arith_expression();
					state._fsp--;

					}
					break;
				case 2 :
					// myCompiler.g:232:6: STRING_LITERAL
					{
					match(input,STRING_LITERAL,FOLLOW_STRING_LITERAL_in_arg685); 
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "arg"



	// $ANTLR start "cond_expression"
	// myCompiler.g:235:1: cond_expression : arith_expression ( RelationOP arith_expression )* ;
	public final void cond_expression() throws RecognitionException {
		try {
			// myCompiler.g:236:16: ( arith_expression ( RelationOP arith_expression )* )
			// myCompiler.g:236:18: arith_expression ( RelationOP arith_expression )*
			{
			pushFollow(FOLLOW_arith_expression_in_cond_expression717);
			arith_expression();
			state._fsp--;

			// myCompiler.g:236:35: ( RelationOP arith_expression )*
			loop8:
			while (true) {
				int alt8=2;
				int LA8_0 = input.LA(1);
				if ( (LA8_0==RelationOP) ) {
					alt8=1;
				}

				switch (alt8) {
				case 1 :
					// myCompiler.g:236:36: RelationOP arith_expression
					{
					match(input,RelationOP,FOLLOW_RelationOP_in_cond_expression720); 
					pushFollow(FOLLOW_arith_expression_in_cond_expression722);
					arith_expression();
					state._fsp--;

					}
					break;

				default :
					break loop8;
				}
			}

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
	}
	// $ANTLR end "cond_expression"



	// $ANTLR start "arith_expression"
	// myCompiler.g:239:1: arith_expression returns [Info theInfo] : a= multExpr ( '+' b= multExpr | '-' multExpr )* ;
	public final Info arith_expression() throws RecognitionException {
		Info theInfo = null;


		Info a =null;
		Info b =null;

		theInfo = new Info();
		try {
			// myCompiler.g:242:17: (a= multExpr ( '+' b= multExpr | '-' multExpr )* )
			// myCompiler.g:242:19: a= multExpr ( '+' b= multExpr | '-' multExpr )*
			{
			pushFollow(FOLLOW_multExpr_in_arith_expression781);
			a=multExpr();
			state._fsp--;

			 theInfo =a; 
			// myCompiler.g:243:18: ( '+' b= multExpr | '-' multExpr )*
			loop9:
			while (true) {
				int alt9=3;
				int LA9_0 = input.LA(1);
				if ( (LA9_0==24) ) {
					alt9=1;
				}
				else if ( (LA9_0==26) ) {
					alt9=2;
				}

				switch (alt9) {
				case 1 :
					// myCompiler.g:243:20: '+' b= multExpr
					{
					match(input,24,FOLLOW_24_in_arith_expression804); 
					pushFollow(FOLLOW_multExpr_in_arith_expression808);
					b=multExpr();
					state._fsp--;


					                       // We need to do type checking first.
					                       // ...
										  
					                       // code generation.					   
					                       if ((a.theType == Type.INT) &&
					                           (b.theType == Type.INT)) {
					                           TextCode.add("%t" + varCount + " = add nsw i32 %t" + theInfo.theVar.varIndex + ", %t" + b.theVar.varIndex);
										   
										       // Update arith_expression's theInfo.
										       theInfo.theType = Type.INT;
										       theInfo.theVar.varIndex = varCount;
										       varCount ++;
					                       } else if ((a.theType == Type.INT) &&
										       (b.theType == Type.CONST_INT)) {
					                           TextCode.add("%t" + varCount + " = add nsw i32 %t" + theInfo.theVar.varIndex + ", " + b.theVar.iValue);
										   
										       // Update arith_expression's theInfo.
										       theInfo.theType = Type.INT;
										       theInfo.theVar.varIndex = varCount;
										       varCount ++;
					                       }
					                    
					}
					break;
				case 2 :
					// myCompiler.g:267:20: '-' multExpr
					{
					match(input,26,FOLLOW_26_in_arith_expression851); 
					pushFollow(FOLLOW_multExpr_in_arith_expression853);
					multExpr();
					state._fsp--;

					}
					break;

				default :
					break loop9;
				}
			}

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
		return theInfo;
	}
	// $ANTLR end "arith_expression"



	// $ANTLR start "multExpr"
	// myCompiler.g:271:1: multExpr returns [Info theInfo] : a= signExpr ( '*' signExpr | '/' signExpr )* ;
	public final Info multExpr() throws RecognitionException {
		Info theInfo = null;


		Info a =null;

		theInfo = new Info();
		try {
			// myCompiler.g:274:11: (a= signExpr ( '*' signExpr | '/' signExpr )* )
			// myCompiler.g:274:13: a= signExpr ( '*' signExpr | '/' signExpr )*
			{
			pushFollow(FOLLOW_signExpr_in_multExpr920);
			a=signExpr();
			state._fsp--;

			 theInfo =a; 
			// myCompiler.g:275:11: ( '*' signExpr | '/' signExpr )*
			loop10:
			while (true) {
				int alt10=3;
				int LA10_0 = input.LA(1);
				if ( (LA10_0==23) ) {
					alt10=1;
				}
				else if ( (LA10_0==27) ) {
					alt10=2;
				}

				switch (alt10) {
				case 1 :
					// myCompiler.g:275:13: '*' signExpr
					{
					match(input,23,FOLLOW_23_in_multExpr936); 
					pushFollow(FOLLOW_signExpr_in_multExpr938);
					signExpr();
					state._fsp--;

					}
					break;
				case 2 :
					// myCompiler.g:276:13: '/' signExpr
					{
					match(input,27,FOLLOW_27_in_multExpr952); 
					pushFollow(FOLLOW_signExpr_in_multExpr954);
					signExpr();
					state._fsp--;

					}
					break;

				default :
					break loop10;
				}
			}

			}

		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
		return theInfo;
	}
	// $ANTLR end "multExpr"



	// $ANTLR start "signExpr"
	// myCompiler.g:280:1: signExpr returns [Info theInfo] : (a= primaryExpr | '-' primaryExpr );
	public final Info signExpr() throws RecognitionException {
		Info theInfo = null;


		Info a =null;

		theInfo = new Info();
		try {
			// myCompiler.g:283:9: (a= primaryExpr | '-' primaryExpr )
			int alt11=2;
			int LA11_0 = input.LA(1);
			if ( (LA11_0==Floating_point_constant||(LA11_0 >= Identifier && LA11_0 <= Integer_constant)||(LA11_0 >= 20 && LA11_0 <= 21)) ) {
				alt11=1;
			}
			else if ( (LA11_0==26) ) {
				alt11=2;
			}

			else {
				NoViableAltException nvae =
					new NoViableAltException("", 11, 0, input);
				throw nvae;
			}

			switch (alt11) {
				case 1 :
					// myCompiler.g:283:11: a= primaryExpr
					{
					pushFollow(FOLLOW_primaryExpr_in_signExpr991);
					a=primaryExpr();
					state._fsp--;

					 theInfo =a; 
					}
					break;
				case 2 :
					// myCompiler.g:284:11: '-' primaryExpr
					{
					match(input,26,FOLLOW_26_in_signExpr1006); 
					pushFollow(FOLLOW_primaryExpr_in_signExpr1008);
					primaryExpr();
					state._fsp--;

					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
		return theInfo;
	}
	// $ANTLR end "signExpr"



	// $ANTLR start "primaryExpr"
	// myCompiler.g:287:1: primaryExpr returns [Info theInfo] : ( Integer_constant | Floating_point_constant | Identifier | '&' Identifier | '(' arith_expression ')' );
	public final Info primaryExpr() throws RecognitionException {
		Info theInfo = null;


		Token Integer_constant5=null;
		Token Identifier6=null;

		theInfo = new Info();
		try {
			// myCompiler.g:290:12: ( Integer_constant | Floating_point_constant | Identifier | '&' Identifier | '(' arith_expression ')' )
			int alt12=5;
			switch ( input.LA(1) ) {
			case Integer_constant:
				{
				alt12=1;
				}
				break;
			case Floating_point_constant:
				{
				alt12=2;
				}
				break;
			case Identifier:
				{
				alt12=3;
				}
				break;
			case 20:
				{
				alt12=4;
				}
				break;
			case 21:
				{
				alt12=5;
				}
				break;
			default:
				NoViableAltException nvae =
					new NoViableAltException("", 12, 0, input);
				throw nvae;
			}
			switch (alt12) {
				case 1 :
					// myCompiler.g:290:14: Integer_constant
					{
					Integer_constant5=(Token)match(input,Integer_constant,FOLLOW_Integer_constant_in_primaryExpr1042); 

					            theInfo.theType = Type.CONST_INT;
								theInfo.theVar.iValue = Integer.parseInt((Integer_constant5!=null?Integer_constant5.getText():null));
					         
					}
					break;
				case 2 :
					// myCompiler.g:295:14: Floating_point_constant
					{
					match(input,Floating_point_constant,FOLLOW_Floating_point_constant_in_primaryExpr1065); 
					}
					break;
				case 3 :
					// myCompiler.g:296:14: Identifier
					{
					Identifier6=(Token)match(input,Identifier,FOLLOW_Identifier_in_primaryExpr1080); 

					                // get type information from symtab.
					                Type the_type = symtab.get((Identifier6!=null?Identifier6.getText():null)).theType;
									theInfo.theType = the_type;

					                // get variable index from symtab.
					                int vIndex = symtab.get((Identifier6!=null?Identifier6.getText():null)).theVar.varIndex;
									
					                switch (the_type) {
					                case INT: 
					                         // get a new temporary variable and
											 // load the variable into the temporary variable.
					                         
											 // Ex: %tx = load i32, i32* %ty.
											 TextCode.add("%t" + varCount + "=load i32, i32* %t" + vIndex);
									         
											 // Now, Identifier's value is at the temporary variable %t[varCount].
											 // Therefore, update it.
											 theInfo.theVar.varIndex = varCount;
											 varCount ++;
					                         break;
					                case FLOAT:
					                         break;
					                case CHAR:
					                         break;
								
					                }
					              
					}
					break;
				case 4 :
					// myCompiler.g:325:7: '&' Identifier
					{
					match(input,20,FOLLOW_20_in_primaryExpr1104); 
					match(input,Identifier,FOLLOW_Identifier_in_primaryExpr1106); 
					}
					break;
				case 5 :
					// myCompiler.g:326:7: '(' arith_expression ')'
					{
					match(input,21,FOLLOW_21_in_primaryExpr1114); 
					pushFollow(FOLLOW_arith_expression_in_primaryExpr1116);
					arith_expression();
					state._fsp--;

					match(input,22,FOLLOW_22_in_primaryExpr1118); 
					}
					break;

			}
		}
		catch (RecognitionException re) {
			reportError(re);
			recover(input,re);
		}
		finally {
			// do for sure before leaving
		}
		return theInfo;
	}
	// $ANTLR end "primaryExpr"

	// Delegated rules



	public static final BitSet FOLLOW_VOID_in_program36 = new BitSet(new long[]{0x0000000000008000L});
	public static final BitSet FOLLOW_MAIN_in_program38 = new BitSet(new long[]{0x0000000000200000L});
	public static final BitSet FOLLOW_21_in_program40 = new BitSet(new long[]{0x0000000000400000L});
	public static final BitSet FOLLOW_22_in_program42 = new BitSet(new long[]{0x0000000040000000L});
	public static final BitSet FOLLOW_30_in_program63 = new BitSet(new long[]{0x0000000080003B10L});
	public static final BitSet FOLLOW_declarations_in_program77 = new BitSet(new long[]{0x0000000080002A00L});
	public static final BitSet FOLLOW_statements_in_program90 = new BitSet(new long[]{0x0000000080000000L});
	public static final BitSet FOLLOW_31_in_program100 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_type_in_declarations127 = new BitSet(new long[]{0x0000000000002000L});
	public static final BitSet FOLLOW_Identifier_in_declarations129 = new BitSet(new long[]{0x0000000010000000L});
	public static final BitSet FOLLOW_28_in_declarations131 = new BitSet(new long[]{0x0000000000001110L});
	public static final BitSet FOLLOW_declarations_in_declarations133 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_INT_in_type190 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_CHAR_in_type200 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_FLOAT_in_type210 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_statement_in_statements221 = new BitSet(new long[]{0x0000000000002A00L});
	public static final BitSet FOLLOW_statements_in_statements223 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_assign_stmt_in_statement254 = new BitSet(new long[]{0x0000000010000000L});
	public static final BitSet FOLLOW_28_in_statement256 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_if_stmt_in_statement269 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_func_no_return_stmt_in_statement282 = new BitSet(new long[]{0x0000000010000000L});
	public static final BitSet FOLLOW_28_in_statement284 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_for_stmt_in_statement297 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_FOR_in_for_stmt314 = new BitSet(new long[]{0x0000000000200000L});
	public static final BitSet FOLLOW_21_in_for_stmt316 = new BitSet(new long[]{0x0000000000002000L});
	public static final BitSet FOLLOW_assign_stmt_in_for_stmt318 = new BitSet(new long[]{0x0000000010000000L});
	public static final BitSet FOLLOW_28_in_for_stmt320 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_cond_expression_in_for_stmt340 = new BitSet(new long[]{0x0000000010000000L});
	public static final BitSet FOLLOW_28_in_for_stmt342 = new BitSet(new long[]{0x0000000000002000L});
	public static final BitSet FOLLOW_assign_stmt_in_for_stmt362 = new BitSet(new long[]{0x0000000000400000L});
	public static final BitSet FOLLOW_22_in_for_stmt378 = new BitSet(new long[]{0x0000000040000000L});
	public static final BitSet FOLLOW_block_stmt_in_for_stmt398 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_if_then_stmt_in_if_stmt434 = new BitSet(new long[]{0x0000000000000040L});
	public static final BitSet FOLLOW_if_else_stmt_in_if_stmt436 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_IF_in_if_then_stmt474 = new BitSet(new long[]{0x0000000000200000L});
	public static final BitSet FOLLOW_21_in_if_then_stmt476 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_cond_expression_in_if_then_stmt478 = new BitSet(new long[]{0x0000000000400000L});
	public static final BitSet FOLLOW_22_in_if_then_stmt480 = new BitSet(new long[]{0x0000000040000000L});
	public static final BitSet FOLLOW_block_stmt_in_if_then_stmt482 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_ELSE_in_if_else_stmt516 = new BitSet(new long[]{0x0000000040000000L});
	public static final BitSet FOLLOW_block_stmt_in_if_else_stmt518 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_30_in_block_stmt559 = new BitSet(new long[]{0x0000000080002A00L});
	public static final BitSet FOLLOW_statements_in_block_stmt561 = new BitSet(new long[]{0x0000000080000000L});
	public static final BitSet FOLLOW_31_in_block_stmt563 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_Identifier_in_assign_stmt575 = new BitSet(new long[]{0x0000000020000000L});
	public static final BitSet FOLLOW_29_in_assign_stmt577 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_arith_expression_in_assign_stmt579 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_Identifier_in_func_no_return_stmt621 = new BitSet(new long[]{0x0000000000200000L});
	public static final BitSet FOLLOW_21_in_func_no_return_stmt623 = new BitSet(new long[]{0x0000000004326400L});
	public static final BitSet FOLLOW_argument_in_func_no_return_stmt625 = new BitSet(new long[]{0x0000000000400000L});
	public static final BitSet FOLLOW_22_in_func_no_return_stmt627 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_arg_in_argument655 = new BitSet(new long[]{0x0000000002000002L});
	public static final BitSet FOLLOW_25_in_argument658 = new BitSet(new long[]{0x0000000004326400L});
	public static final BitSet FOLLOW_arg_in_argument660 = new BitSet(new long[]{0x0000000002000002L});
	public static final BitSet FOLLOW_arith_expression_in_arg678 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_STRING_LITERAL_in_arg685 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_arith_expression_in_cond_expression717 = new BitSet(new long[]{0x0000000000010002L});
	public static final BitSet FOLLOW_RelationOP_in_cond_expression720 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_arith_expression_in_cond_expression722 = new BitSet(new long[]{0x0000000000010002L});
	public static final BitSet FOLLOW_multExpr_in_arith_expression781 = new BitSet(new long[]{0x0000000005000002L});
	public static final BitSet FOLLOW_24_in_arith_expression804 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_multExpr_in_arith_expression808 = new BitSet(new long[]{0x0000000005000002L});
	public static final BitSet FOLLOW_26_in_arith_expression851 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_multExpr_in_arith_expression853 = new BitSet(new long[]{0x0000000005000002L});
	public static final BitSet FOLLOW_signExpr_in_multExpr920 = new BitSet(new long[]{0x0000000008800002L});
	public static final BitSet FOLLOW_23_in_multExpr936 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_signExpr_in_multExpr938 = new BitSet(new long[]{0x0000000008800002L});
	public static final BitSet FOLLOW_27_in_multExpr952 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_signExpr_in_multExpr954 = new BitSet(new long[]{0x0000000008800002L});
	public static final BitSet FOLLOW_primaryExpr_in_signExpr991 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_26_in_signExpr1006 = new BitSet(new long[]{0x0000000000306400L});
	public static final BitSet FOLLOW_primaryExpr_in_signExpr1008 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_Integer_constant_in_primaryExpr1042 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_Floating_point_constant_in_primaryExpr1065 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_Identifier_in_primaryExpr1080 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_20_in_primaryExpr1104 = new BitSet(new long[]{0x0000000000002000L});
	public static final BitSet FOLLOW_Identifier_in_primaryExpr1106 = new BitSet(new long[]{0x0000000000000002L});
	public static final BitSet FOLLOW_21_in_primaryExpr1114 = new BitSet(new long[]{0x0000000004306400L});
	public static final BitSet FOLLOW_arith_expression_in_primaryExpr1116 = new BitSet(new long[]{0x0000000000400000L});
	public static final BitSet FOLLOW_22_in_primaryExpr1118 = new BitSet(new long[]{0x0000000000000002L});
}
