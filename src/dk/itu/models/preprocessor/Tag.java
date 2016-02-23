package dk.itu.models.preprocessor;

public final class Tag {

	public static final String comment = "//";
	
	public static final String IF = "#if";
	
	public static final String IFDEF = "#ifdef";
	
	public static final String IFNDEF = "#ifndef";
	
	public static final String ELSE = "#else";
	
	public static final String ELIF = "#elif";
	
	public static final String ENDIF = "#endif";
	
	public static final String INCLUDE = "#include";
	
	public static final String regex = "^\\s*"+"(" + IF + "|" 
			+ IFDEF + "|" + IFNDEF + "|" + ELSE + "|" 
			+ ELIF + "|"+ ENDIF + "|" + INCLUDE
			+ ")\\s*(.*)\\s*$";
	
}
