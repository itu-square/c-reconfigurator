package dk.itu.models.preprocessor;

public final class Tag {

	public static final String comment = "//";
	
	public  static final String    IF = "#if";
	private static final String regIF = "#\\s*if ";
	
	public  static final String    IFDEF = "#ifdef";
	private static final String regIFDEF = "#\\s*ifdef ";
	
	public  static final String    IFNDEF = "#ifndef";
	private static final String regIFNDEF = "#\\s*ifndef ";
	
	public  static final String    ELSE = "#else";
	private static final String regELSE = "#\\s*else ";
	
	public  static final String    ELIF = "#elif";
	private static final String regELIF = "#\\s*elif ";
	
	public  static final String    ENDIF = "#endif";
	private static final String regENDIF = "#\\s*endif ";
	
	public  static final String    INCLUDE = "#include";
	private static final String regINCLUDE = "#\\s*include ";
	
	public static final String regex = "^\\s*"+"(" + regIF + "|" 
			+ regIFDEF + "|" + regIFNDEF + "|" + regELSE + "|" 
			+ regELIF + "|"+ regENDIF + "|" + regINCLUDE
			+ ")\\s*(.*)\\s*$";
	
}
