package dk.itu.models.preprocessor;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class Preprocessor {

	private String defs = ""; // defs are the features (e.g. DEBUG, LOGGING, etc)
	private ContextManager context = ContextManager.getContext();
	private Map<String, String> mapFeatureAndTransformedFeatureNames;

	private Preprocessor() {
		mapFeatureAndTransformedFeatureNames = new HashMap<String, String>();
	}

	public void execute() throws Exception {
		if (context.getSrcfile() == null || context.getDestfile() == null) {
			throw new Exception(
					"Some parameter missed. Make sure that definition list, input and output files are provided.");
		}

		try {
			preprocess();
		} catch (IOException e) {
			throw new Exception("IO error while preprocessing", e);
		}
	}

	private void preprocess() throws IOException {
		BufferedReader br = null; // for reading from file

		try {
			br = new BufferedReader(new FileReader(context.getSrcfile()));

			/**
			 * Gets the defined features, split them by "," and, finally, remove
			 * all duplicate white spaces
			 */		
			Set set = new HashSet(Arrays.asList(defs.replaceAll("\\s+", "")
					.split(",")));

			// Compiles the regex then sets the pattern
			Pattern pattern = Pattern.compile(Tag.regex,
					Pattern.CASE_INSENSITIVE);

			String line;
			int lineNumber = 0; // for counting the line number
			int currentLevel = 0; // for controling the tags (e.g., ifdefs and
									// endifs)
			int removeLevel = -1; // if -1 can write, otherwise cannot
			boolean skip = false; // this flag serves to control code within a
									// certain feature

			// reading line-by-line from input file
			while ((line = br.readLine()) != null) {
				lineNumber++;

				/**
				 * Creates a matcher that will match 
				 * the given input against this pattern.
				 */
				Matcher matcher = pattern.matcher(line);

				/**
				 * Matches the defined pattern with the current line
				 */
				if (matcher.matches()) {
					/**
					 * MatchResult is unaffected by subsequent operations
					 */
					MatchResult result = matcher.toMatchResult();
					String dir = result.group(1).toLowerCase(); // cpp directive
					String param = result.group(2); // feature expression

					if (Tag.IFDEF.equals(dir) || Tag.IF.equals(dir)) {
						saveFeatureNamesIntoMap(param);
						
						//adds ifdef X on the stack
						context.addDirective(dir + " "
								+ removeWhitespace(param));

						// verifies if the feature was defined
						if (defs.replaceAll("\\s+", "").length() > 0) {
							skip = !set.contains(param);
						} else {
							skip = false;
						}

						if (removeLevel == -1 && skip) {
							removeLevel = currentLevel;
						}
						currentLevel++;
						continue;
					} else if (Tag.IFNDEF.equals(dir)) {
						saveFeatureNamesIntoMap(param);

						context.addDirective(dir + " " + param);
						
						if (defs.replaceAll("\\s+", "").length() > 0) {
							skip = set.contains(param);
						} else {
							skip = false;
						}
						
						if (removeLevel == -1 && skip) {
							removeLevel = currentLevel;
						}
						currentLevel++;
						continue;
					} else if (Tag.ELSE.equals(dir)) {
						currentLevel--;
						if (currentLevel == removeLevel) {
							removeLevel = -1;
						}
						if (removeLevel == -1 && !skip) {
							removeLevel = currentLevel;
						}
						currentLevel++;
						continue;
					} else if (Tag.ENDIF.equals(dir)) {

						if (context.stackIsEmpty()) {
							System.out
									.println("#endif encountered without "
											+ "corresponding #if or #ifdef or #ifndef");
							return;
						}

						context.removeTopDirective();

						currentLevel--;
						if (currentLevel == removeLevel) {
							removeLevel = -1;
						}
						continue;
					}
				} 
//				if (removeLevel == -1 || currentLevel < removeLevel) {
//					bw.write(line);
//					bw.newLine();
//				}
			}
		} finally {
			if (br != null) {
				br.close();
			}
		}

	}
		
	private void writeTransformedFeatureNamesToFile() throws IOException {
		BufferedWriter bw = new BufferedWriter(new FileWriter(context.getDestfile()));
		
		// header
		bw.write("typedef int feature;");
		bw.newLine();
		
		for (String reconfiguredFeature : mapFeatureAndTransformedFeatureNames.values()) {
			bw.write("feature " + reconfiguredFeature + ";");
			bw.newLine();
		}
		
		bw.close();
	}

	private void writeFeatureToFile(BufferedWriter bw, String param) throws IOException {
		
		List<String> features = getFeatureNames(param);
		
		for (String featureName : features) {
			bw.write("feature _reconfig_"+ featureName +";");
			bw.newLine();
		}
	}
	
	private void saveFeatureNamesIntoMap(String param) {
		List<String> features = getFeatureNames(param);
		
		for (String featureName : features) {
			String transformedFeatureName = "_reconfig_"+ featureName;
			mapFeatureAndTransformedFeatureNames.put(featureName, transformedFeatureName);
		}
	}
	
	private List<String> getFeatureNames(String featureExpression) {
		List<String> featureNames = new ArrayList<String>();
		
		featureExpression = removeWhitespace(featureExpression);
		featureExpression = removeKeywords(featureExpression);
		featureExpression = removeParentheses(featureExpression);
		featureExpression = removeOperators(featureExpression);
		
		String[] features = featureExpression.split(",");
		for (String feature : features) {
			featureNames.add(feature);	
		}
		
		return featureNames;
	}

	private String removeOperators(String featureExpression) {
		return featureExpression.replaceAll("&&|\\|\\|", ",");
	}

	private String removeParentheses(String featureExpression) {
		return featureExpression.replaceAll("\\(|\\)|!", "");
	}

	private String removeKeywords(String featureExpression) {
		return featureExpression.replaceAll("defined|def|ndef", "");
	}

	private String removeWhitespace(String featureExpression) {
		return featureExpression.replaceAll("\\s", "");
	}
	
	public Map<String, String> getMapFeatureAndTransformedFeatureNames() {
		return mapFeatureAndTransformedFeatureNames;
	}
	
	public Set<String> getOriginalFeatureNames() {
		return mapFeatureAndTransformedFeatureNames.keySet();
	}
	
	public Collection<String> getTransformedFeatureNames() {
		return mapFeatureAndTransformedFeatureNames.values();
	}

	public String getDefs() {
		return defs;
	}

	public void setDefs(String defs) {
		this.defs = defs;
	}
	
	public static void main(String[] args) {
		ContextManager manager = ContextManager.getContext();
		String dirpath = "test/eb91f1d/"; //input
		
		try {
			Preprocessor pp = new Preprocessor();

			File dir = new File(dirpath);
			
			if (dir.isDirectory()) {
				manager.setDestfile(dirpath+"REconfig.c");
				File[] files = dir.listFiles();

				for (File file : files) {
					try {
						String filepath = file.getCanonicalPath();
						if (filepath.endsWith(".c") || filepath.endsWith(".h")) {
							manager.setSrcfile(filepath);
						}
						pp.execute();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			} else {
				manager.setDestfile(dir.getParent() + File.separator + "REconfig.c");
				manager.setSrcfile(dirpath);
			}

			pp.execute();
			pp.writeTransformedFeatureNamesToFile(); //output: REconfig.c with all features listed 
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}