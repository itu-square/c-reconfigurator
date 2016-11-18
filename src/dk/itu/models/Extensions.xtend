package dk.itu.models

import com.google.common.collect.AbstractIterator
import com.google.common.collect.FluentIterable
import com.google.common.collect.UnmodifiableIterator
import com.google.common.io.Files
import dk.itu.models.checks.CheckContainsIf1
import dk.itu.models.rules.phase3variables.ReplaceDeclaratorTextRule
import dk.itu.models.rules.phase3variables.ReplaceIdentifierRule
import dk.itu.models.rules.phase3variables.RewriteVariableUseRule
import dk.itu.models.rules.phase4functions.RenameFunctionRule
import dk.itu.models.rules.phase4functions.RewriteFunctionCallRule
import dk.itu.models.strategies.TopDownStrategy
import dk.itu.models.utils.DeclarationPCMap
import java.io.BufferedReader
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.FileReader
import java.io.IOException
import java.io.PrintStream
import java.io.PrintWriter
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import java.util.HashMap
import java.util.Iterator
import java.util.List
import org.eclipse.xtext.xbase.lib.Functions.Function1
import org.eclipse.xtext.xbase.lib.Functions.Function2
import us.cuny.qc.cs.babbage.Minimize
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

class Extensions {


	static private var minimizeCache = new HashMap<String, String>

	public static def String folder(String filePath) {
		filePath.substring(0, filePath.lastIndexOf(File.separator) + 1)
	}
	
	public static def String relativeTo(String path, String base) {
		if (path.startsWith(base)) { '''«path.substring(base.length)»''' }
		else path
	}
	
	public static def void writeToFile(String text, String file) {
		println("Writing file: " + file)
		val fileObject = new File(file)
		if (!fileObject.parentFile.exists) {
			Files.createParentDirs(fileObject)
		}
		
		if (fileObject.exists) {
			fileObject.delete
		}
			
		try {
			var PrintWriter file_output = new PrintWriter(new FileOutputStream(file, true));
			file_output.write(text);
			file_output.flush();
			file_output.close();
		} catch (IOException e) {
			throw new Exception(
				'''Can not recover from the input or output fault: «e.message» {«fileObject.parentFile.exists»}''', e);
		}
	}
	
	public static def String readFile(String fileName) throws IOException {
	    val BufferedReader br = new BufferedReader(new FileReader(fileName));
	    try {
	        val StringBuilder sb = new StringBuilder();
	        var String line = br.readLine();
	
	        while (line != null) {
	            sb.append(line);
	            sb.append("\n");
	            line = br.readLine();
	        }
	        return sb.toString();
	    } finally {
	        br.close();
	    }
	}
	
	public static def printCode(Object o) {
		PrintCode::printCode(o)
	}
	
	public static def printAST(Object o) {
		PrintAST::printAST(o)
	}
	
	
	public static def Pair<?> toPair(List<?> node) {
		node.toPair
	}

	public static def Pair<Object> toPair(Iterable<Object> node) {
		var Pair<Object> p = Pair.empty()
		for (var i = node.size - 1; i >= 0; i--) {
			p = new Pair(node.get(i), p)
		}
		p
	}
	
	public static def Pair<Object> subPair(Pair<Object> p, int startInclusive, int endExclusive) {
		p.filterIndexed[e, i| startInclusive<=i && i<endExclusive].toPair
	}
	
	
	public static def boolean structurallyEquals(Pair<Object> i1, Pair<Object> i2) {
		if (i1 == i2) return true // referential equality
		
		var Pair<Object> p1 = i1
		var Pair<Object> p2 = i2
		
		while (!p1.isEmpty && !p2.isEmpty) {
			
			switch (true) {
				case
					p1.head.class != p2.head.class : return false
				case
					p1.head instanceof PresenceCondition
					&& p2.head instanceof PresenceCondition
					&& !(p1.head as PresenceCondition).is(p2.head as PresenceCondition) : return false
				case
					p1.head instanceof Language<?>
					&& p2.head instanceof Language<?>
					&& !(p1.head as Language<CTag>).printAST.equals((p2.head as Language<CTag>).printAST) : return false
				case
					p1.head instanceof GNode
					&& p2.head instanceof GNode
					&& !(p1.head as GNode).printAST.equals((p2.head as GNode).printAST) : return false
			}
			
			p1 = p1.tail
			p2 = p2.tail
		}

    	return p1.isEmpty && p2.isEmpty
  }
	
	
	private static def <T> UnmodifiableIterator<T> filterIndexedHelper(Iterable<T> unfiltered, Function2<? super T, Integer, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<T>() {
			val iterator = unfiltered.iterator
			private var index = 0
			override protected T computeNext() {
				while (iterator.hasNext()) {
					val T element = iterator.next();
					if (predicate.apply(element, index++)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def <T> Iterable<T> filterIndexed (Iterable<T> unfiltered, Function2<? super T, Integer, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		return new FluentIterable<T>() {
			override public Iterator<T> iterator() {
				return filterIndexedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	
	private static def <T> UnmodifiableIterator<T> filterFixedHelper(Iterable<T> unfiltered, Function2<? super T, Iterable<T>, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<T>() {
			val iterator = unfiltered.iterator
			override protected T computeNext() {
				while (iterator.hasNext()) {
					val T element = iterator.next();
					if (predicate.apply(element, unfiltered)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def <T> Iterable<T> filterFixed (Iterable<T> unfiltered, Function2<? super T, Iterable<T>, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		return new FluentIterable<T>() {
			override public Iterator<T> iterator() {
				return filterFixedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	private static def filterFixedHelper(Node unfiltered, Function2<Object, Node, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		if (predicate == null) throw new NullPointerException();
		return new AbstractIterator<Object>() {
			val iterator = unfiltered.iterator
			override protected computeNext() {
				while (iterator.hasNext()) {
					val Object element = iterator.next();
					if (predicate.apply(element, unfiltered)) {
						return element;
					}
				}
				return endOfData();
			}
		};
  	}
	
	public static def filterFixed (Node unfiltered, Function2<Object, Node, Boolean> predicate) {
		if (unfiltered == null) throw new NullPointerException();
		return new FluentIterable<Object>() {
			override public Iterator<Object> iterator() {
				return filterFixedHelper(unfiltered, predicate);
			}
		}
	}
	
	
	public static def <I,O> O pipe(I i, Function1<? super I, O> f) {
		f.apply(i)
	}
	
	public static def Pair<Object> getChildrenGuardedBy(GNode node, PresenceCondition pc) {
		var Pair<Object> p = Pair.EMPTY
		var index = node.indexOf(pc) + 1
		while (index < node.size && !(node.get(index) instanceof PresenceCondition)) {
			p = p.add(node.get(index++))
		}
		p
	}
	
	public static def boolean containsConditional(Node node) {
		ContainsConditional::containsConditional(node)
	}
	
	public static def boolean checkContainsIf1(Node node) {
		CheckContainsIf1::check(node)
	}
	
	// PresenceCondition to Minimized expression
	public static def String PCtoMexp(PresenceCondition cond, HashMap<String, String> varMap) {
		val HashMap<String, String> varMapInverse = new HashMap<String, String>
		val char a = 'a'
		val bdd = cond.BDD
		val vars = Reconfigurator.presenceConditionManager.variableManager
		
		if (bdd.isOne()) {
			return "1"
		} else if (bdd.isZero()) {
			return "0"
      	}
		
		val StringBuilder mexp = new StringBuilder
		
		var firstConjunction = true;
		for (Object o : bdd.allsat()) {
			if (!firstConjunction) { mexp.append("+") } 

			var byte[] sat = o as byte[]
			for (var i = 0; i < sat.length; i++) {

				if(sat.get(i) >= 0) {
					var id = vars.getName(i)
					id = if (id.startsWith("(defined"))
						"def_" + id.substring(9, id.length-1)
						else id
					if (!varMapInverse.containsKey(id)) {
						val shortId = ((a + varMapInverse.size)as char).toString
						varMapInverse.put(id, shortId)
						varMap.put(shortId, id)
					}
					id = varMapInverse.get(id)
					mexp.append(id)
				}
				if(sat.get(i) == 0) {	
					mexp.append("'")
				}
			}
        	firstConjunction = false
		}
		
		mexp.toString
	}
	
	// Minimized expression to C preprocessor expression
	public static def String MexptoCPPexp(String mexp, HashMap<String, String> varMap) {
		val StringBuilder output = new StringBuilder
		val input = mexp.toCharArray
		var firstConjunction = true
			
		for (var i = 0; i < input.length; i++) {
			val current = input.get(i)
			
			if ((current.toString).equals("+")) {
				output.append(" || ")
				firstConjunction = true
			} else if (!(current.toString).equals("'") && !(current.toString).equals(" ")) {
				if (firstConjunction == false) {
					output.append(" && ")
				}
				if(i < input.length -1 && (input.get(i+1).toString).equals("'"))
					output.append("!")
				val id = varMap.get(current.toString)
				if (id.startsWith("def_"))
					output.append('''defined(«id.substring(4)»)''')
				else
					output.append(id)
				firstConjunction = false
			}
		}
		output.toString
	}
	
	// PresenceCondition direct to C preprocessor expression shortcut
	public static def String PCtoCPPexp(PresenceCondition condition) {
		if (condition.toString.equals("1")) "1"
		else if (condition.toString.equals("0")) "0"
		else {
			val varMap = new HashMap<String, String>
			var mexp = condition.PCtoMexp(varMap)
			if (Settings::minimize) {
				if (minimizeCache.containsKey(mexp)) {
					mexp = minimizeCache.get(mexp)
				} else {		
					val mini = Minimize::process(mexp, new PrintStream(new ByteArrayOutputStream))
					minimizeCache.put(mexp, mini)
					mexp = mini
				}
			}
			mexp.MexptoCPPexp(varMap)
		}
	}

	// Minimized expression to C expression
	public static def GNode MexptoCexp(String mexp, HashMap<String, String> varMap) {
		var GNode disj
		val input = mexp.toCharArray
			
		var GNode conj
		for (var i = 0; i < input.length; i++) {
			val current = input.get(i)
			
			if ((current.toString).equals("+")) {
				if(disj == null) { disj = conj }
				else { disj = GNode::create("LogicalORExpression", disj, new Language<CTag>(CTag.OROR), conj) }
        		conj = null;
			} else if (!(current.toString).equals("'") && !(current.toString).equals(" ")) {
				var id = varMap.get(current.toString)
				if (id.startsWith("def_")) {
					if (Reconfigurator::transformedFeaturemap.containsKey(id.substring(4)))
						id = Reconfigurator::transformedFeaturemap.get(id.substring(4))
					else {
						Reconfigurator::transformedFeaturemap.put(id.substring(4), "_reconfig_" + id.substring(4))
						id = "_reconfig_" + id.substring(4)
					}
				}	
				var term = GNode::create("PrimaryIdentifier", new Text<CTag>(CTag.IDENTIFIER, id))
				
				if(i < input.length -1 && (input.get(i+1).toString).equals("'"))
					term = GNode::create("UnaryExpression",
							GNode::create("Unaryoperator", new Language<CTag>(CTag.NOT)),
							term)
					
				if(conj == null) { conj = term }
				else { conj = GNode::create("LogicalAndExpression", conj, new Language<CTag>(CTag.ANDAND), term) }
			}
		}
		
		if(disj == null) { disj = conj }
		else { disj = GNode::create("LogicalORExpression", disj, new Language<CTag>(CTag.OROR), conj) }

		GNode::create("PrimaryExpression",
				new Language<CTag>(CTag.LPAREN),
				disj,
				new Language<CTag>(CTag.RPAREN))
    }

	// PresenceCondition direct to C expression shortcut
	public static def GNode PCtoCexp(PresenceCondition condition) {
		if (condition.toString.equals("1")) throw new Exception("Return a Language literal 1")
		else if (condition.toString.equals("0")) throw new Exception("Return a Language literal 0")
		else {
			val varMap = new HashMap<String, String>
			var mexp = condition.PCtoMexp(varMap)
			if (Settings::minimize) {
				if (minimizeCache.containsKey(mexp)) {
					mexp = minimizeCache.get(mexp)
				} else {		
					val mini = Minimize::process(mexp, new PrintStream(new ByteArrayOutputStream))
					minimizeCache.put(mexp, mini)
					mexp = mini
				}
			}
			mexp.MexptoCexp(varMap)
		}
	}
	
	private static def void getNestedNodesLocations(Node node, ArrayList<String> locations) {
		for(Object child : node) {
			if (child instanceof Node) {
				val location = (child as Node).location
				if (location != null && !locations.contains(location.file))
					locations.add(location.file)
				getNestedNodesLocations(child as Node, locations)
			}
		}
	}
	
	public static def List<String> getNestedNodesLocations(Node node)
	{
		val ArrayList<String> locations = new ArrayList<String>
		if (node.location != null)
			locations.add(node.location.file)
		getNestedNodesLocations(node, locations)
		return locations
	}
	
	public static def Node getDescendantNode(Node node, Function1<Node, Boolean> test) {
		for(Object child : node) {
			if (child instanceof Node) {
				if (test.apply(child))
					return child
				else {
					val r = (child as Node).getDescendantNode(test)
					if (r != null) return r
				}
			}
		}
		return null
	}
	
	public static def Node getDescendantNode(Node node, String nodeName) {
		node.getDescendantNode[name.equals(nodeName)]
	}
	
	public static def boolean containsTypedef(Node node) {
		node.getDescendantNode[
			it instanceof Language<?>
			&& (it as Language<CTag>).tag.equals(CTag::TYPEDEF)
		] != null
	}
	
	public static def replaceDeclaratorTextWithNewId (GNode node, String newId) {
    	val tdn = new TopDownStrategy
    	tdn.register(new ReplaceDeclaratorTextRule(newId))
    	tdn.transform(node) as GNode
    }
	
	public static def renameFunctionWithNewId (GNode node, String newId) {
    	val tdn = new TopDownStrategy
    	tdn.register(new RenameFunctionRule(newId))
    	tdn.transform(node) as GNode
    }
    
    public static def rewriteVariableUse (
    	GNode node,
		ArrayList<SimpleEntry<GNode,DeclarationPCMap>> variableDeclarationScopes,
		PresenceCondition pc,
		PresenceConditionIdMap pcidmap ) {
			val tdn = new TopDownStrategy
			tdn.register(new RewriteVariableUseRule(variableDeclarationScopes, pc, pcidmap))
			tdn.transform(node) as GNode
	}

	public static def replaceIdentifierVarName (GNode node, String oldName, String newName) {
    	val tdn = new TopDownStrategy
    	tdn.register(new ReplaceIdentifierRule(oldName, newName))
    	tdn.transform(node) as GNode
    }
    
    public static def rewriteFunctionCall (
    	GNode node,
		DeclarationPCMap fmap,
		PresenceCondition pc,
		PresenceConditionIdMap pcidmap ) {
    		val tdn = new TopDownStrategy
			tdn.register(new RewriteFunctionCallRule(fmap, pc, pcidmap))
			tdn.transform(node) as GNode
	}
	
	
	
	public static def Iterable<PresenceCondition> firstNestedPCs(Node node) {
		if (node.name.equals("Conditional")) {
			return node.filter(PresenceCondition)
		} else {
			for (GNode child : node.filter(GNode)) {
				val res = child.firstNestedPCs
				if (res.size != 0) return res
			}
			return #[]
		}
	}
}