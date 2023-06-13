// Generated from c:\Users\u005Cuser\OneDrive\орн▒\compiler\project\project\myCompiler.g by ANTLR 4.9.2

    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;

import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class myCompilerParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.9.2", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, T__7=8, T__8=9, 
		T__9=10, T__10=11, T__11=12, FLOAT=13, INT=14, CHAR=15, MAIN=16, VOID=17, 
		IF=18, ELSE=19, FOR=20, RelationOP=21, Identifier=22, Integer_constant=23, 
		Floating_point_constant=24, STRING_LITERAL=25, WS=26, COMMENT=27;
	public static final int
		RULE_program = 0, RULE_declarations = 1, RULE_type = 2, RULE_statements = 3, 
		RULE_statement = 4, RULE_for_stmt = 5, RULE_if_stmt = 6, RULE_if_then_stmt = 7, 
		RULE_if_else_stmt = 8, RULE_block_stmt = 9, RULE_assign_stmt = 10, RULE_func_no_return_stmt = 11, 
		RULE_argument = 12, RULE_arg = 13, RULE_cond_expression = 14, RULE_arith_expression = 15, 
		RULE_multExpr = 16, RULE_signExpr = 17, RULE_primaryExpr = 18;
	private static String[] makeRuleNames() {
		return new String[] {
			"program", "declarations", "type", "statements", "statement", "for_stmt", 
			"if_stmt", "if_then_stmt", "if_else_stmt", "block_stmt", "assign_stmt", 
			"func_no_return_stmt", "argument", "arg", "cond_expression", "arith_expression", 
			"multExpr", "signExpr", "primaryExpr"
		};
	}
	public static final String[] ruleNames = makeRuleNames();

	private static String[] makeLiteralNames() {
		return new String[] {
			null, "'('", "')'", "'{'", "'}'", "';'", "'='", "','", "'+'", "'-'", 
			"'*'", "'/'", "'&'", "'float'", "'int'", "'char'", "'main'", "'void'", 
			"'if'", "'else'", "'for'"
		};
	}
	private static final String[] _LITERAL_NAMES = makeLiteralNames();
	private static String[] makeSymbolicNames() {
		return new String[] {
			null, null, null, null, null, null, null, null, null, null, null, null, 
			null, "FLOAT", "INT", "CHAR", "MAIN", "VOID", "IF", "ELSE", "FOR", "RelationOP", 
			"Identifier", "Integer_constant", "Floating_point_constant", "STRING_LITERAL", 
			"WS", "COMMENT"
		};
	}
	private static final String[] _SYMBOLIC_NAMES = makeSymbolicNames();
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "myCompiler.g"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }


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

	public myCompilerParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	public static class ProgramContext extends ParserRuleContext {
		public TerminalNode VOID() { return getToken(myCompilerParser.VOID, 0); }
		public TerminalNode MAIN() { return getToken(myCompilerParser.MAIN, 0); }
		public DeclarationsContext declarations() {
			return getRuleContext(DeclarationsContext.class,0);
		}
		public StatementsContext statements() {
			return getRuleContext(StatementsContext.class,0);
		}
		public ProgramContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_program; }
	}

	public final ProgramContext program() throws RecognitionException {
		ProgramContext _localctx = new ProgramContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_program);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(38);
			match(VOID);
			setState(39);
			match(MAIN);
			setState(40);
			match(T__0);
			setState(41);
			match(T__1);

			           /* Output function prologue */
			           prologue();
			        
			setState(43);
			match(T__2);
			setState(44);
			declarations();
			setState(45);
			statements();
			setState(46);
			match(T__3);

				   if (TRACEON)
				      System.out.println("VOID MAIN () {declarations statements}");

			           /* output function epilogue */	  
			           epilogue();
			        
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class DeclarationsContext extends ParserRuleContext {
		public TypeContext type() {
			return getRuleContext(TypeContext.class,0);
		}
		public TerminalNode Identifier() { return getToken(myCompilerParser.Identifier, 0); }
		public DeclarationsContext declarations() {
			return getRuleContext(DeclarationsContext.class,0);
		}
		public DeclarationsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_declarations; }
	}

	public final DeclarationsContext declarations() throws RecognitionException {
		DeclarationsContext _localctx = new DeclarationsContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_declarations);
		try {
			setState(56);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case FLOAT:
			case INT:
			case CHAR:
				enterOuterAlt(_localctx, 1);
				{
				setState(49);
				type();
				setState(50);
				match(Identifier);
				setState(51);
				match(T__4);
				setState(52);
				declarations();

				           if (TRACEON)
				              System.out.println("declarations: type Identifier : declarations");

				           if (symtab.containsKey((((DeclarationsContext)_localctx).Identifier!=null?((DeclarationsContext)_localctx).Identifier.getText():null))) {
				              // variable re-declared.
				              System.out.println("Type Error: " + 
				                                  ((DeclarationsContext)_localctx).Identifier.getLine() + 
				                                 ": Redeclared identifier.");
				              System.exit(0);
				           }
				                 
				           /* Add ID and its info into the symbol table. */
					       Info the_entry = new Info();
						   the_entry.theType = ((DeclarationsContext)_localctx).type.attr_type;
						   the_entry.theVar.varIndex = varCount;
						   varCount ++;
						   symtab.put((((DeclarationsContext)_localctx).Identifier!=null?((DeclarationsContext)_localctx).Identifier.getText():null), the_entry);

				           // issue the instruction.
						   // Ex: \%a = alloca i32, align 4
				           if (((DeclarationsContext)_localctx).type.attr_type == Type.INT) { 
				              TextCode.add("\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
				           }
				        
				}
				break;
			case T__3:
			case IF:
			case FOR:
			case Identifier:
				enterOuterAlt(_localctx, 2);
				{

				           if (TRACEON)
				              System.out.println("declarations: ");
				        
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class TypeContext extends ParserRuleContext {
		public Type attr_type;
		public TerminalNode INT() { return getToken(myCompilerParser.INT, 0); }
		public TerminalNode CHAR() { return getToken(myCompilerParser.CHAR, 0); }
		public TerminalNode FLOAT() { return getToken(myCompilerParser.FLOAT, 0); }
		public TypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_type; }
	}

	public final TypeContext type() throws RecognitionException {
		TypeContext _localctx = new TypeContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_type);
		try {
			setState(64);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case INT:
				enterOuterAlt(_localctx, 1);
				{
				setState(58);
				match(INT);
				 if (TRACEON) System.out.println("type: INT"); ((TypeContext)_localctx).attr_type = Type.INT; 
				}
				break;
			case CHAR:
				enterOuterAlt(_localctx, 2);
				{
				setState(60);
				match(CHAR);
				 if (TRACEON) System.out.println("type: CHAR"); ((TypeContext)_localctx).attr_type = Type.CHAR; 
				}
				break;
			case FLOAT:
				enterOuterAlt(_localctx, 3);
				{
				setState(62);
				match(FLOAT);
				if (TRACEON) System.out.println("type: FLOAT"); ((TypeContext)_localctx).attr_type = Type.FLOAT; 
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StatementsContext extends ParserRuleContext {
		public StatementContext statement() {
			return getRuleContext(StatementContext.class,0);
		}
		public StatementsContext statements() {
			return getRuleContext(StatementsContext.class,0);
		}
		public StatementsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statements; }
	}

	public final StatementsContext statements() throws RecognitionException {
		StatementsContext _localctx = new StatementsContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_statements);
		try {
			setState(70);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case IF:
			case FOR:
			case Identifier:
				enterOuterAlt(_localctx, 1);
				{
				setState(66);
				statement();
				setState(67);
				statements();
				}
				break;
			case T__3:
				enterOuterAlt(_localctx, 2);
				{
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StatementContext extends ParserRuleContext {
		public Assign_stmtContext assign_stmt() {
			return getRuleContext(Assign_stmtContext.class,0);
		}
		public If_stmtContext if_stmt() {
			return getRuleContext(If_stmtContext.class,0);
		}
		public Func_no_return_stmtContext func_no_return_stmt() {
			return getRuleContext(Func_no_return_stmtContext.class,0);
		}
		public For_stmtContext for_stmt() {
			return getRuleContext(For_stmtContext.class,0);
		}
		public StatementContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_statement; }
	}

	public final StatementContext statement() throws RecognitionException {
		StatementContext _localctx = new StatementContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_statement);
		try {
			setState(80);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,3,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(72);
				assign_stmt();
				setState(73);
				match(T__4);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(75);
				if_stmt();
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(76);
				func_no_return_stmt();
				setState(77);
				match(T__4);
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(79);
				for_stmt();
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class For_stmtContext extends ParserRuleContext {
		public TerminalNode FOR() { return getToken(myCompilerParser.FOR, 0); }
		public List<Assign_stmtContext> assign_stmt() {
			return getRuleContexts(Assign_stmtContext.class);
		}
		public Assign_stmtContext assign_stmt(int i) {
			return getRuleContext(Assign_stmtContext.class,i);
		}
		public Cond_expressionContext cond_expression() {
			return getRuleContext(Cond_expressionContext.class,0);
		}
		public Block_stmtContext block_stmt() {
			return getRuleContext(Block_stmtContext.class,0);
		}
		public For_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_for_stmt; }
	}

	public final For_stmtContext for_stmt() throws RecognitionException {
		For_stmtContext _localctx = new For_stmtContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_for_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(82);
			match(FOR);
			setState(83);
			match(T__0);
			setState(84);
			assign_stmt();
			setState(85);
			match(T__4);
			setState(86);
			cond_expression();
			setState(87);
			match(T__4);
			setState(88);
			assign_stmt();
			setState(89);
			match(T__1);
			setState(90);
			block_stmt();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class If_stmtContext extends ParserRuleContext {
		public If_then_stmtContext if_then_stmt() {
			return getRuleContext(If_then_stmtContext.class,0);
		}
		public If_else_stmtContext if_else_stmt() {
			return getRuleContext(If_else_stmtContext.class,0);
		}
		public If_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_if_stmt; }
	}

	public final If_stmtContext if_stmt() throws RecognitionException {
		If_stmtContext _localctx = new If_stmtContext(_ctx, getState());
		enterRule(_localctx, 12, RULE_if_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(92);
			if_then_stmt();
			setState(93);
			if_else_stmt();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class If_then_stmtContext extends ParserRuleContext {
		public TerminalNode IF() { return getToken(myCompilerParser.IF, 0); }
		public Cond_expressionContext cond_expression() {
			return getRuleContext(Cond_expressionContext.class,0);
		}
		public Block_stmtContext block_stmt() {
			return getRuleContext(Block_stmtContext.class,0);
		}
		public If_then_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_if_then_stmt; }
	}

	public final If_then_stmtContext if_then_stmt() throws RecognitionException {
		If_then_stmtContext _localctx = new If_then_stmtContext(_ctx, getState());
		enterRule(_localctx, 14, RULE_if_then_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(95);
			match(IF);
			setState(96);
			match(T__0);
			setState(97);
			cond_expression();
			setState(98);
			match(T__1);
			setState(99);
			block_stmt();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class If_else_stmtContext extends ParserRuleContext {
		public TerminalNode ELSE() { return getToken(myCompilerParser.ELSE, 0); }
		public Block_stmtContext block_stmt() {
			return getRuleContext(Block_stmtContext.class,0);
		}
		public If_else_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_if_else_stmt; }
	}

	public final If_else_stmtContext if_else_stmt() throws RecognitionException {
		If_else_stmtContext _localctx = new If_else_stmtContext(_ctx, getState());
		enterRule(_localctx, 16, RULE_if_else_stmt);
		try {
			setState(104);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case ELSE:
				enterOuterAlt(_localctx, 1);
				{
				setState(101);
				match(ELSE);
				setState(102);
				block_stmt();
				}
				break;
			case T__3:
			case IF:
			case FOR:
			case Identifier:
				enterOuterAlt(_localctx, 2);
				{
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Block_stmtContext extends ParserRuleContext {
		public StatementsContext statements() {
			return getRuleContext(StatementsContext.class,0);
		}
		public Block_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_block_stmt; }
	}

	public final Block_stmtContext block_stmt() throws RecognitionException {
		Block_stmtContext _localctx = new Block_stmtContext(_ctx, getState());
		enterRule(_localctx, 18, RULE_block_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(106);
			match(T__2);
			setState(107);
			statements();
			setState(108);
			match(T__3);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Assign_stmtContext extends ParserRuleContext {
		public TerminalNode Identifier() { return getToken(myCompilerParser.Identifier, 0); }
		public Arith_expressionContext arith_expression() {
			return getRuleContext(Arith_expressionContext.class,0);
		}
		public Assign_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_assign_stmt; }
	}

	public final Assign_stmtContext assign_stmt() throws RecognitionException {
		Assign_stmtContext _localctx = new Assign_stmtContext(_ctx, getState());
		enterRule(_localctx, 20, RULE_assign_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(110);
			match(Identifier);
			setState(111);
			match(T__5);
			setState(112);
			arith_expression();

			                Info theRHS = ((Assign_stmtContext)_localctx).arith_expression.theInfo;
							Info theLHS = symtab.get((((Assign_stmtContext)_localctx).Identifier!=null?((Assign_stmtContext)_localctx).Identifier.getText():null)); 
					   
			                if ((theLHS.theType == Type.INT) &&
			                    (theRHS.theType == Type.INT)) {		   
			                   // issue store insruction.
			                   // Ex: store i32 \%tx, i32* \%ty
			                   TextCode.add("store i32 \%t" + theRHS.theVar.varIndex + ", i32* \%t" + theLHS.theVar.varIndex);
							} else if ((theLHS.theType == Type.INT) &&
							    (theRHS.theType == Type.CONST_INT)) {
			                   // issue store insruction.
			                   // Ex: store i32 value, i32* \%ty
			                   TextCode.add("store i32 " + theRHS.theVar.iValue + ", i32* \%t" + theLHS.theVar.varIndex);				
							}
						 
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Func_no_return_stmtContext extends ParserRuleContext {
		public TerminalNode Identifier() { return getToken(myCompilerParser.Identifier, 0); }
		public ArgumentContext argument() {
			return getRuleContext(ArgumentContext.class,0);
		}
		public Func_no_return_stmtContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_func_no_return_stmt; }
	}

	public final Func_no_return_stmtContext func_no_return_stmt() throws RecognitionException {
		Func_no_return_stmtContext _localctx = new Func_no_return_stmtContext(_ctx, getState());
		enterRule(_localctx, 22, RULE_func_no_return_stmt);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(115);
			match(Identifier);
			setState(116);
			match(T__0);
			setState(117);
			argument();
			setState(118);
			match(T__1);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ArgumentContext extends ParserRuleContext {
		public List<ArgContext> arg() {
			return getRuleContexts(ArgContext.class);
		}
		public ArgContext arg(int i) {
			return getRuleContext(ArgContext.class,i);
		}
		public ArgumentContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_argument; }
	}

	public final ArgumentContext argument() throws RecognitionException {
		ArgumentContext _localctx = new ArgumentContext(_ctx, getState());
		enterRule(_localctx, 24, RULE_argument);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(120);
			arg();
			setState(125);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__6) {
				{
				{
				setState(121);
				match(T__6);
				setState(122);
				arg();
				}
				}
				setState(127);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ArgContext extends ParserRuleContext {
		public Arith_expressionContext arith_expression() {
			return getRuleContext(Arith_expressionContext.class,0);
		}
		public TerminalNode STRING_LITERAL() { return getToken(myCompilerParser.STRING_LITERAL, 0); }
		public ArgContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arg; }
	}

	public final ArgContext arg() throws RecognitionException {
		ArgContext _localctx = new ArgContext(_ctx, getState());
		enterRule(_localctx, 26, RULE_arg);
		try {
			setState(130);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__0:
			case T__8:
			case T__11:
			case Identifier:
			case Integer_constant:
			case Floating_point_constant:
				enterOuterAlt(_localctx, 1);
				{
				setState(128);
				arith_expression();
				}
				break;
			case STRING_LITERAL:
				enterOuterAlt(_localctx, 2);
				{
				setState(129);
				match(STRING_LITERAL);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Cond_expressionContext extends ParserRuleContext {
		public List<Arith_expressionContext> arith_expression() {
			return getRuleContexts(Arith_expressionContext.class);
		}
		public Arith_expressionContext arith_expression(int i) {
			return getRuleContext(Arith_expressionContext.class,i);
		}
		public List<TerminalNode> RelationOP() { return getTokens(myCompilerParser.RelationOP); }
		public TerminalNode RelationOP(int i) {
			return getToken(myCompilerParser.RelationOP, i);
		}
		public Cond_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_cond_expression; }
	}

	public final Cond_expressionContext cond_expression() throws RecognitionException {
		Cond_expressionContext _localctx = new Cond_expressionContext(_ctx, getState());
		enterRule(_localctx, 28, RULE_cond_expression);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(132);
			arith_expression();
			setState(137);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==RelationOP) {
				{
				{
				setState(133);
				match(RelationOP);
				setState(134);
				arith_expression();
				}
				}
				setState(139);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class Arith_expressionContext extends ParserRuleContext {
		public Info theInfo;
		public MultExprContext a;
		public MultExprContext b;
		public List<MultExprContext> multExpr() {
			return getRuleContexts(MultExprContext.class);
		}
		public MultExprContext multExpr(int i) {
			return getRuleContext(MultExprContext.class,i);
		}
		public Arith_expressionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_arith_expression; }
	}

	public final Arith_expressionContext arith_expression() throws RecognitionException {
		Arith_expressionContext _localctx = new Arith_expressionContext(_ctx, getState());
		enterRule(_localctx, 30, RULE_arith_expression);
		theInfo = new Info();
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(140);
			((Arith_expressionContext)_localctx).a = multExpr();
			 ((Arith_expressionContext)_localctx).theInfo = ((Arith_expressionContext)_localctx).a.theInfo; 
			setState(150);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__7 || _la==T__8) {
				{
				setState(148);
				_errHandler.sync(this);
				switch (_input.LA(1)) {
				case T__7:
					{
					setState(142);
					match(T__7);
					setState(143);
					((Arith_expressionContext)_localctx).b = multExpr();

					                       // We need to do type checking first.
					                       // ...
										  
					                       // code generation.					   
					                       if ((((Arith_expressionContext)_localctx).a.theInfo.theType == Type.INT) &&
					                           (((Arith_expressionContext)_localctx).b.theInfo.theType == Type.INT)) {
					                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + _localctx.theInfo.theVar.varIndex + ", \%t" + ((Arith_expressionContext)_localctx).b.theInfo.theVar.varIndex);
										   
										       // Update arith_expression's theInfo.
										       _localctx.theInfo.theType = Type.INT;
										       _localctx.theInfo.theVar.varIndex = varCount;
										       varCount ++;
					                       } else if ((((Arith_expressionContext)_localctx).a.theInfo.theType == Type.INT) &&
										       (((Arith_expressionContext)_localctx).b.theInfo.theType == Type.CONST_INT)) {
					                           TextCode.add("\%t" + varCount + " = add nsw i32 \%t" + _localctx.theInfo.theVar.varIndex + ", " + ((Arith_expressionContext)_localctx).b.theInfo.theVar.iValue);
										   
										       // Update arith_expression's theInfo.
										       _localctx.theInfo.theType = Type.INT;
										       _localctx.theInfo.theVar.varIndex = varCount;
										       varCount ++;
					                       }
					                    
					}
					break;
				case T__8:
					{
					setState(146);
					match(T__8);
					setState(147);
					multExpr();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
				setState(152);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class MultExprContext extends ParserRuleContext {
		public Info theInfo;
		public SignExprContext a;
		public List<SignExprContext> signExpr() {
			return getRuleContexts(SignExprContext.class);
		}
		public SignExprContext signExpr(int i) {
			return getRuleContext(SignExprContext.class,i);
		}
		public MultExprContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_multExpr; }
	}

	public final MultExprContext multExpr() throws RecognitionException {
		MultExprContext _localctx = new MultExprContext(_ctx, getState());
		enterRule(_localctx, 32, RULE_multExpr);
		theInfo = new Info();
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(153);
			((MultExprContext)_localctx).a = signExpr();
			 ((MultExprContext)_localctx).theInfo = ((MultExprContext)_localctx).a.theInfo; 
			setState(161);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__9 || _la==T__10) {
				{
				setState(159);
				_errHandler.sync(this);
				switch (_input.LA(1)) {
				case T__9:
					{
					setState(155);
					match(T__9);
					setState(156);
					signExpr();
					}
					break;
				case T__10:
					{
					setState(157);
					match(T__10);
					setState(158);
					signExpr();
					}
					break;
				default:
					throw new NoViableAltException(this);
				}
				}
				setState(163);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class SignExprContext extends ParserRuleContext {
		public Info theInfo;
		public PrimaryExprContext a;
		public PrimaryExprContext primaryExpr() {
			return getRuleContext(PrimaryExprContext.class,0);
		}
		public SignExprContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_signExpr; }
	}

	public final SignExprContext signExpr() throws RecognitionException {
		SignExprContext _localctx = new SignExprContext(_ctx, getState());
		enterRule(_localctx, 34, RULE_signExpr);
		theInfo = new Info();
		try {
			setState(169);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case T__0:
			case T__11:
			case Identifier:
			case Integer_constant:
			case Floating_point_constant:
				enterOuterAlt(_localctx, 1);
				{
				setState(164);
				((SignExprContext)_localctx).a = primaryExpr();
				 ((SignExprContext)_localctx).theInfo = ((SignExprContext)_localctx).a.theInfo; 
				}
				break;
			case T__8:
				enterOuterAlt(_localctx, 2);
				{
				setState(167);
				match(T__8);
				setState(168);
				primaryExpr();
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class PrimaryExprContext extends ParserRuleContext {
		public Info theInfo;
		public TerminalNode Integer_constant() { return getToken(myCompilerParser.Integer_constant, 0); }
		public TerminalNode Floating_point_constant() { return getToken(myCompilerParser.Floating_point_constant, 0); }
		public TerminalNode Identifier() { return getToken(myCompilerParser.Identifier, 0); }
		public Arith_expressionContext arith_expression() {
			return getRuleContext(Arith_expressionContext.class,0);
		}
		public PrimaryExprContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_primaryExpr; }
	}

	public final PrimaryExprContext primaryExpr() throws RecognitionException {
		PrimaryExprContext _localctx = new PrimaryExprContext(_ctx, getState());
		enterRule(_localctx, 36, RULE_primaryExpr);
		theInfo = new Info();
		try {
			setState(182);
			_errHandler.sync(this);
			switch (_input.LA(1)) {
			case Integer_constant:
				enterOuterAlt(_localctx, 1);
				{
				setState(171);
				match(Integer_constant);

				            _localctx.theInfo.theType = Type.CONST_INT;
							_localctx.theInfo.theVar.iValue = Integer.parseInt((((PrimaryExprContext)_localctx).Integer_constant!=null?((PrimaryExprContext)_localctx).Integer_constant.getText():null));
				         
				}
				break;
			case Floating_point_constant:
				enterOuterAlt(_localctx, 2);
				{
				setState(173);
				match(Floating_point_constant);
				}
				break;
			case Identifier:
				enterOuterAlt(_localctx, 3);
				{
				setState(174);
				match(Identifier);

				                // get type information from symtab.
				                Type the_type = symtab.get((((PrimaryExprContext)_localctx).Identifier!=null?((PrimaryExprContext)_localctx).Identifier.getText():null)).theType;
								_localctx.theInfo.theType = the_type;

				                // get variable index from symtab.
				                int vIndex = symtab.get((((PrimaryExprContext)_localctx).Identifier!=null?((PrimaryExprContext)_localctx).Identifier.getText():null)).theVar.varIndex;
								
				                switch (the_type) {
				                case INT: 
				                         // get a new temporary variable and
										 // load the variable into the temporary variable.
				                         
										 // Ex: \%tx = load i32, i32* \%ty.
										 TextCode.add("\%t" + varCount + "=load i32, i32* \%t" + vIndex);
								         
										 // Now, Identifier's value is at the temporary variable \%t[varCount].
										 // Therefore, update it.
										 _localctx.theInfo.theVar.varIndex = varCount;
										 varCount ++;
				                         break;
				                case FLOAT:
				                         break;
				                case CHAR:
				                         break;
							
				                }
				              
				}
				break;
			case T__11:
				enterOuterAlt(_localctx, 4);
				{
				setState(176);
				match(T__11);
				setState(177);
				match(Identifier);
				}
				break;
			case T__0:
				enterOuterAlt(_localctx, 5);
				{
				setState(178);
				match(T__0);
				setState(179);
				arith_expression();
				setState(180);
				match(T__1);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\35\u00bb\4\2\t\2"+
		"\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13"+
		"\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22\t\22"+
		"\4\23\t\23\4\24\t\24\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\3\3"+
		"\3\3\3\3\3\3\3\3\3\3\3\5\3;\n\3\3\4\3\4\3\4\3\4\3\4\3\4\5\4C\n\4\3\5\3"+
		"\5\3\5\3\5\5\5I\n\5\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\5\6S\n\6\3\7\3\7\3"+
		"\7\3\7\3\7\3\7\3\7\3\7\3\7\3\7\3\b\3\b\3\b\3\t\3\t\3\t\3\t\3\t\3\t\3\n"+
		"\3\n\3\n\5\nk\n\n\3\13\3\13\3\13\3\13\3\f\3\f\3\f\3\f\3\f\3\r\3\r\3\r"+
		"\3\r\3\r\3\16\3\16\3\16\7\16~\n\16\f\16\16\16\u0081\13\16\3\17\3\17\5"+
		"\17\u0085\n\17\3\20\3\20\3\20\7\20\u008a\n\20\f\20\16\20\u008d\13\20\3"+
		"\21\3\21\3\21\3\21\3\21\3\21\3\21\3\21\7\21\u0097\n\21\f\21\16\21\u009a"+
		"\13\21\3\22\3\22\3\22\3\22\3\22\3\22\7\22\u00a2\n\22\f\22\16\22\u00a5"+
		"\13\22\3\23\3\23\3\23\3\23\3\23\5\23\u00ac\n\23\3\24\3\24\3\24\3\24\3"+
		"\24\3\24\3\24\3\24\3\24\3\24\3\24\5\24\u00b9\n\24\3\24\2\2\25\2\4\6\b"+
		"\n\f\16\20\22\24\26\30\32\34\36 \"$&\2\2\2\u00bb\2(\3\2\2\2\4:\3\2\2\2"+
		"\6B\3\2\2\2\bH\3\2\2\2\nR\3\2\2\2\fT\3\2\2\2\16^\3\2\2\2\20a\3\2\2\2\22"+
		"j\3\2\2\2\24l\3\2\2\2\26p\3\2\2\2\30u\3\2\2\2\32z\3\2\2\2\34\u0084\3\2"+
		"\2\2\36\u0086\3\2\2\2 \u008e\3\2\2\2\"\u009b\3\2\2\2$\u00ab\3\2\2\2&\u00b8"+
		"\3\2\2\2()\7\23\2\2)*\7\22\2\2*+\7\3\2\2+,\7\4\2\2,-\b\2\1\2-.\7\5\2\2"+
		"./\5\4\3\2/\60\5\b\5\2\60\61\7\6\2\2\61\62\b\2\1\2\62\3\3\2\2\2\63\64"+
		"\5\6\4\2\64\65\7\30\2\2\65\66\7\7\2\2\66\67\5\4\3\2\678\b\3\1\28;\3\2"+
		"\2\29;\b\3\1\2:\63\3\2\2\2:9\3\2\2\2;\5\3\2\2\2<=\7\20\2\2=C\b\4\1\2>"+
		"?\7\21\2\2?C\b\4\1\2@A\7\17\2\2AC\b\4\1\2B<\3\2\2\2B>\3\2\2\2B@\3\2\2"+
		"\2C\7\3\2\2\2DE\5\n\6\2EF\5\b\5\2FI\3\2\2\2GI\3\2\2\2HD\3\2\2\2HG\3\2"+
		"\2\2I\t\3\2\2\2JK\5\26\f\2KL\7\7\2\2LS\3\2\2\2MS\5\16\b\2NO\5\30\r\2O"+
		"P\7\7\2\2PS\3\2\2\2QS\5\f\7\2RJ\3\2\2\2RM\3\2\2\2RN\3\2\2\2RQ\3\2\2\2"+
		"S\13\3\2\2\2TU\7\26\2\2UV\7\3\2\2VW\5\26\f\2WX\7\7\2\2XY\5\36\20\2YZ\7"+
		"\7\2\2Z[\5\26\f\2[\\\7\4\2\2\\]\5\24\13\2]\r\3\2\2\2^_\5\20\t\2_`\5\22"+
		"\n\2`\17\3\2\2\2ab\7\24\2\2bc\7\3\2\2cd\5\36\20\2de\7\4\2\2ef\5\24\13"+
		"\2f\21\3\2\2\2gh\7\25\2\2hk\5\24\13\2ik\3\2\2\2jg\3\2\2\2ji\3\2\2\2k\23"+
		"\3\2\2\2lm\7\5\2\2mn\5\b\5\2no\7\6\2\2o\25\3\2\2\2pq\7\30\2\2qr\7\b\2"+
		"\2rs\5 \21\2st\b\f\1\2t\27\3\2\2\2uv\7\30\2\2vw\7\3\2\2wx\5\32\16\2xy"+
		"\7\4\2\2y\31\3\2\2\2z\177\5\34\17\2{|\7\t\2\2|~\5\34\17\2}{\3\2\2\2~\u0081"+
		"\3\2\2\2\177}\3\2\2\2\177\u0080\3\2\2\2\u0080\33\3\2\2\2\u0081\177\3\2"+
		"\2\2\u0082\u0085\5 \21\2\u0083\u0085\7\33\2\2\u0084\u0082\3\2\2\2\u0084"+
		"\u0083\3\2\2\2\u0085\35\3\2\2\2\u0086\u008b\5 \21\2\u0087\u0088\7\27\2"+
		"\2\u0088\u008a\5 \21\2\u0089\u0087\3\2\2\2\u008a\u008d\3\2\2\2\u008b\u0089"+
		"\3\2\2\2\u008b\u008c\3\2\2\2\u008c\37\3\2\2\2\u008d\u008b\3\2\2\2\u008e"+
		"\u008f\5\"\22\2\u008f\u0098\b\21\1\2\u0090\u0091\7\n\2\2\u0091\u0092\5"+
		"\"\22\2\u0092\u0093\b\21\1\2\u0093\u0097\3\2\2\2\u0094\u0095\7\13\2\2"+
		"\u0095\u0097\5\"\22\2\u0096\u0090\3\2\2\2\u0096\u0094\3\2\2\2\u0097\u009a"+
		"\3\2\2\2\u0098\u0096\3\2\2\2\u0098\u0099\3\2\2\2\u0099!\3\2\2\2\u009a"+
		"\u0098\3\2\2\2\u009b\u009c\5$\23\2\u009c\u00a3\b\22\1\2\u009d\u009e\7"+
		"\f\2\2\u009e\u00a2\5$\23\2\u009f\u00a0\7\r\2\2\u00a0\u00a2\5$\23\2\u00a1"+
		"\u009d\3\2\2\2\u00a1\u009f\3\2\2\2\u00a2\u00a5\3\2\2\2\u00a3\u00a1\3\2"+
		"\2\2\u00a3\u00a4\3\2\2\2\u00a4#\3\2\2\2\u00a5\u00a3\3\2\2\2\u00a6\u00a7"+
		"\5&\24\2\u00a7\u00a8\b\23\1\2\u00a8\u00ac\3\2\2\2\u00a9\u00aa\7\13\2\2"+
		"\u00aa\u00ac\5&\24\2\u00ab\u00a6\3\2\2\2\u00ab\u00a9\3\2\2\2\u00ac%\3"+
		"\2\2\2\u00ad\u00ae\7\31\2\2\u00ae\u00b9\b\24\1\2\u00af\u00b9\7\32\2\2"+
		"\u00b0\u00b1\7\30\2\2\u00b1\u00b9\b\24\1\2\u00b2\u00b3\7\16\2\2\u00b3"+
		"\u00b9\7\30\2\2\u00b4\u00b5\7\3\2\2\u00b5\u00b6\5 \21\2\u00b6\u00b7\7"+
		"\4\2\2\u00b7\u00b9\3\2\2\2\u00b8\u00ad\3\2\2\2\u00b8\u00af\3\2\2\2\u00b8"+
		"\u00b0\3\2\2\2\u00b8\u00b2\3\2\2\2\u00b8\u00b4\3\2\2\2\u00b9\'\3\2\2\2"+
		"\20:BHRj\177\u0084\u008b\u0096\u0098\u00a1\u00a3\u00ab\u00b8";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}