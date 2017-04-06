package dk.itu.models.preprocessor;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

public class ContextManager {
	// for features and their line number
	private Map<String, Set<Integer>> mapFeatures;
	private Map<Integer, Set<String>> mapLineNumberFeature;
	// for controlling the pairs ifdef-endifs
	public static Stack<String> stackDirectives;

	private String srcfile; // input path file
	private String destfile; // output path file

	// singleton
	private static ContextManager instance = new ContextManager();

	private ContextManager() {
		mapFeatures = new HashMap<String, Set<Integer>>();
		mapLineNumberFeature = new HashMap<Integer, Set<String>>();
		stackDirectives = new Stack<String>();
	}

	public static ContextManager getContext() {
		return instance;
	}
	
	public void addInfo(Integer lineNumber, String feature) {
		// verifica se jah existe a feature no map
		if (mapLineNumberFeature.containsKey(lineNumber)) {
			Set<String> setOldValues = mapLineNumberFeature.get(lineNumber);
			setOldValues.add(feature);
			mapLineNumberFeature.put(lineNumber, setOldValues);
			return;
		}
		Set<String> set = new HashSet<String>();
		set.add(feature);
		
		mapLineNumberFeature.put(lineNumber, set);
	}

	public void addFeatureInfo(String key, Integer value) {
		// verifica se jah existe a feature no map
		if (mapFeatures.containsKey(key)) {
			Set<Integer> setOldValues = mapFeatures.get(key);
			setOldValues.add(value);
			mapFeatures.put(key, setOldValues);
			return;
		}
		Set<Integer> setLineNumbers = new HashSet<Integer>();
		setLineNumbers.add(value);
		
		mapFeatures.put(key, setLineNumbers);
	}

	public String getSrcfile() {
		return srcfile;
	}

	public void setSrcfile(String srcfile) {
		this.srcfile = srcfile;
	}

	public String getDestfile() {
		return destfile;
	}

	public void setDestfile(String destfile) {
		this.destfile = destfile;
	}
	
	public Map<Integer,Set<String>> getMap() {
		return mapLineNumberFeature;
	}

	/**
	 * This method is called for getting number lines.
	 * 
	 * @param feature
	 *            - the key of the map
	 * @return number lines or null
	 */
	public Set<Integer> getLineNumbersbyFeature(String feature) {

		if (mapFeatures.containsKey(feature))
			return mapFeatures.get(feature);
		else
			return null;
	}
	
	public Set<String> getFeaturesByLine(Integer line) {
		if(mapLineNumberFeature.containsKey(line)) {
			return mapLineNumberFeature.get(line);
		} else {
			return null;
		}
	}

	public Map<String, Set<Integer>> getMapFeatures() {
		return mapFeatures;
	}

	public void addDirective(String ifdef) {
		stackDirectives.push(ifdef);
	}

	public void removeTopDirective() {
		stackDirectives.pop();
	}

	public String getTopDirective() {
		if (!stackDirectives.isEmpty())
			return stackDirectives.peek();
		return null; //empty
	}
	
	public boolean stackIsEmpty(){
		return stackDirectives.isEmpty();
	}
	
	public int stackSize(){
		return stackDirectives.size();
	}

	public void clearAll() {
		mapFeatures.clear();
		stackDirectives.clear();
	}
	
}
