package dk.itu.models

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*
import java.io.File

class PrintCode extends PrintMethod {
	
	// the indentation prefix; add or remove spaces from it
	static private var indent = ""

	static private var last_C_line = ""
	static private var last_line = ""

	static private var firstToken = true

	static def String printCode(Object o) {
		indent = ""
		last_C_line = ""
		last_line = ""
		firstToken = true
		ancestors = new ArrayList<Node>
		output = new StringBuilder
		t(o)
		output.toString
	}

	static def private dispatch void t(PresenceCondition condition) {
		
		var current_line = last_line
		
		if (last_line.equals("#if")) {
			val cond = condition.PCtoCPPexp
			output.print(''' «cond»''')
			current_line += ''' «cond»'''
		} else {
			var disPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			for (PresenceCondition pc : ancestors.last.filter(PresenceCondition).filter[ancestors.last.indexOf(it)<ancestors.last.indexOf(condition)]) {
				disPC = disPC.or(pc)
			}
			val newPC = Reconfigurator::presenceConditionManager.newPresenceCondition(condition.BDD.constrain(disPC.BDD.not))
			
			output.println
			output.print(indent)
			output.print(last_C_line.replaceAll(".", " "))
			
			if (newPC.isTrue) {
				output.print('''#else''')
				current_line = '''#else'''
			} else {
				val cond = newPC.PCtoCPPexp
				output.print('''#elif «cond»''')
				current_line = '''#elif «cond»'''
			}
		}
		
		last_line = current_line
	}

	static def private dispatch void t(Language<CTag> language) {
		
		var current_C_line = last_C_line
		var current_line = last_line
		
		if (last_line.startsWith("#")) {
			output.println
			current_line = ""
		}
		
		
		val Node iter = ancestors.findLast[name.equals("IterationStatement")]
		val int chld_idx = if (iter === null) -1 else {
			if (iter.equals(ancestors.last)) iter.indexOf(language) else iter.indexOf(ancestors.get(ancestors.indexOf(iter) +1))}
		val Node lpar = if (iter === null) null else iter.findFirst[toString.equals("(")] as Node
		val int lpar_idx = if (lpar === null) -1 else iter.indexOf(lpar)
		val Node rpar = if (iter === null) null else iter.findFirst[toString.equals(")")] as Node
		val int rpar_idx = if (rpar === null) -1 else iter.indexOf(rpar)
		val boolean iterationExpression =
			chld_idx != -1 && lpar_idx != -1 && rpar_idx != -1
			&& lpar_idx < chld_idx && chld_idx < rpar_idx
		
		if(language.toString === null) {
			ancestors.forEach[println("- " + it.name)]
			println(ancestors.findFirst[it.name.equals("FunctionCall")].printAST)
		}
		
		if (
			(last_line.endsWith(";") && !iterationExpression)
			|| last_line.endsWith("{") || last_line.endsWith("}")
			|| language.toString.equals("{")
		) {
			if (!last_line.startsWith("#"))
				output.println
			current_C_line = ""
			current_line = ""
		}
		
		if (language.toString.equals("}")) {
			indent = indent.substring(4)
			current_C_line = ""
			current_line = ""
		}
		
		if (current_C_line.isEmpty || last_line.startsWith("#"))
			output.print(indent)
		
		if (last_line.startsWith("#") && !last_C_line.endsWith(";")) {
			output.print(current_C_line.replaceAll(".", " "))
 		}

		if (
			!last_C_line.isEmpty
			&& !last_C_line.endsWith("(") && (!last_C_line.endsWith(";") || iterationExpression) && !last_C_line.endsWith("{") && !last_C_line.endsWith("!") && !last_line.endsWith("}")
			&& !language.toString.equals(")") && !language.toString.equals("{") && !language.toString.equals("}") && !language.toString.equals(";")
			&& !#["UnaryIdentifierDeclarator", "UnaryAbstractDeclarator"].contains(ancestors.last.name)
		) {
			output.print(" ")
			current_C_line += " "
			current_line += " "
 		}
 		
		output.print(language.toString)
		current_C_line += language.toString
		current_line += language.toString
		
		last_C_line = current_C_line
		last_line = current_line
		
		if (language.toString.equals("{")) {
			indent += "    "
		}
	}

	static def private dispatch void t(GNode node) {
		
		val locs = node.nestedNodesLocations
		
		if (
			!Settings::printIncludes
			&& ancestors.size >= 1
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& !locs.contains(Reconfigurator::file)
		) {
			return
		}
		
		var PresenceCondition lastPC
		
		var preconditional_C_line = last_C_line
		var current_C_line = last_C_line
		var current_line = last_line
		
		if(
			#["Declaration", "DeclarationExtension", "FunctionDefinition"].contains(node.name)
			&& !ancestors.exists[it.is_GNode("FunctionDefinition")]
			&& (!last_line.startsWith("#") || last_line.startsWith("#include")) && !last_line.empty
		) {
			output.println
			current_C_line = ""
			current_line = ""
		}
		
		if(
			#["Declaration", "DeclarationExtension", "FunctionDefinition"].contains(node.name)
			&& !ancestors.exists[it.is_GNode("DeclarationExtension")]
		) {
			if (node.location !== null) {
				output.println
				output.print('''// «Settings::sourceRoot.parentFile.toPath.relativize(new File(node.location.file).toPath) »:«node.location.line»:«node.location.column»''')
				if(last_line.empty && !(node.properties !== null && node.hasProperty("OriginalPC")))
					output.println
			}
			
			if (node.properties !== null && node.hasProperty("OriginalPC")) {
				output.println
				output.print('''// «node.getProperty("OriginalPC").as_PresenceCondition.PCtoCPPexp»''')
				if(last_line.empty)
					output.println
			}
		}
		
		// IF or ELSE with a single statement
		if(
			ancestors.last !== null
			&& ancestors.last.name.equals("SelectionStatement")
			&& ancestors.last.indexOf(node) > 0
			&& ancestors.last.get(ancestors.last.indexOf(node)-1) instanceof Language<?>
			&& ((ancestors.last.get(ancestors.last.indexOf(node)-1) as Language<CTag>).tag.equals(CTag::RPAREN)
				|| (ancestors.last.get(ancestors.last.indexOf(node)-1) as Language<CTag>).tag.equals(CTag::^ELSE))
			&& #["ExpressionStatement", "ReturnStatement"].contains(node.name)
		) {
			output.println
			output.print("        ")
			current_C_line = "        "
			current_line = "        "
		}
		
		// FOR with a single statement
		if(
			ancestors.last !== null
			&& ancestors.last.name.equals("IterationStatement")
			&& ancestors.last.indexOf(node) > 0
			&& ancestors.last.get(ancestors.last.indexOf(node)-1) instanceof Language<?>
			&& (ancestors.last.get(ancestors.last.indexOf(node)-1) as Language<CTag>).tag.equals(CTag::RPAREN)
			&& node.name.equals("ExpressionStatement")
		) {
			output.println
			output.print("        ")
			current_C_line = "        "
			current_line = "        "
		}
		
		if (
			node.name.equals("Enumerator") && last_C_line.endsWith(",")
		) {
			output.println
			output.print(indent.substring(4))
			last_C_line = current_C_line = ""
			last_line = current_line = ""
					
		}
		
		if (node.name.equals("Conditional")) {
			
			if (!last_line.empty && !last_line.endsWith("{")) {
				output.println
				current_line = ""
			}
			
			if (last_C_line.endsWith(";") || last_C_line.endsWith("{") || last_C_line.endsWith("}")) {
				output.println
				current_C_line = ""
				current_line = ""
			}
			
			output.print(indent)
			
			output.print(current_C_line.replaceAll(".", " "))
			output.print("#if")
			current_line += "#if"

			last_C_line = current_C_line
			last_line = current_line
			
			ancestors.add(node)
			for (Object it : node) {
				if (it.is_PresenceCondition) {
					if (lastPC === null) {
						lastPC = it.as_PresenceCondition
					} else if (lastPC.isMutuallyExclusive(it.as_PresenceCondition)) {
						lastPC = lastPC.or(it.as_PresenceCondition)
						last_C_line = preconditional_C_line
					} else {
						lastPC = it.as_PresenceCondition
					}
				}
				t(it)
			}
			ancestors.remove(node)
			
			output.println
			output.print(indent)
			if (!preconditional_C_line.endsWith(";") && !preconditional_C_line.endsWith("{"))
				output.print(preconditional_C_line.replaceAll(".", " "))
			output.print("#endif")
			last_line = "#endif"

		} else if (node.name.equals("ConditionalExpression")) {
			
			output.println
			output.print(indent)
			output.print(current_C_line.replaceAll(".", " "))

			last_C_line = current_C_line
			last_line = current_line
			
			ancestors.add(node)
			for (Object it : node) {
				if (
					it instanceof Language<?>
					&& ((it as Language<CTag>).tag.equals(CTag::QUESTION)
						|| (it as Language<CTag>).tag.equals(CTag::COLON))
				) {
					output.println
					output.print(indent)
					output.print(preconditional_C_line.replaceAll(".", " "))
		
					last_C_line = preconditional_C_line
					last_line = preconditional_C_line
				}
				t(it)
			}
			ancestors.remove(node)
		} else if (
			   node.name.equals("Declaration")
			
			&& node.get(0).is_GNode("DeclaringList")
			
			&& node.get(0).as_GNode.get(0).toString.equals("char")
			
			&& node.get(0).as_GNode.get(1).is_GNode("ArrayDeclarator")
			
			&& node.get(0).as_GNode.get(1).as_GNode.get(0).is_GNode("SimpleDeclarator")
			&& node.get(0).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.startsWith(Settings::reconfiguratorIncludePlaceholder)
			
			&& node.get(0).as_GNode.get(4).is_GNode("InitializerOpt")
			&& node.get(0).as_GNode.get(4).as_GNode.get(1).is_GNode("Initializer")
			
			&& node.get(0).as_GNode.get(4).as_GNode.get(1).as_GNode.get(0).is_GNode("StringLiteralList")
			&& node.get(0).as_GNode.get(4).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.startsWith("\"#include")
		) {
			var includeStrLit = node.get(0).as_GNode.get(4).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString
			includeStrLit = includeStrLit.subSequence(1, includeStrLit.length-1).toString
			
			if (!last_line.startsWith("#include")) {
				output.println
			}
			
			if (node.get(0).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.equals(Settings::reconfiguratorIncludePlaceholder)) {
				if (node.properties !== null && node.hasProperty("OriginalPC")) {
					output.println
					output.println('''#if «node.getProperty("OriginalPC").as_PresenceCondition.PCtoCPPexp»''')
					if (Settings::printIncludes) output.print("// BEGIN ")
					output.println(includeStrLit.replace("\\\"", "\""))
//					output.println('''#endif''')
//					last_line = "#endif"
				} else {
					output.print(indent)
					if (Settings::printIncludes) output.print("// BEGIN ")
					output.print(includeStrLit.replace("\\\"", "\""))
					last_line = includeStrLit
				}
			} else if (node.get(0).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.equals(Settings::reconfiguratorIncludePlaceholderEnd)) {
				if (node.properties !== null && node.hasProperty("OriginalPC")) {
					output.println
//					output.println('''#if «node.getProperty("OriginalPC").as_PresenceCondition.PCtoCPPexp»''')
					if (Settings::printIncludes) output.print("// END ")
					output.println(includeStrLit.replace("\\\"", "\""))
					output.println('''#endif''')
					last_line = "#endif"
				} else {
					output.print(indent)
					if (Settings::printIncludes) output.print("// END ")
					output.print(includeStrLit.replace("\\\"", "\""))
					last_line = includeStrLit
				}
			}
		} else {
			ancestors.add(node)
			for (Object it : node) {
				if (
					it.is_GNode("Conditional")
					&& it.as_GNode.filter(PresenceCondition).size == 1
				) {
					val pc = it.as_GNode.get(0).as_PresenceCondition
					if (lastPC === null) {
						lastPC = pc
					} else if (lastPC.isMutuallyExclusive(pc)) {
						lastPC = lastPC.or(pc)
						last_C_line = preconditional_C_line
					} else {
						lastPC = pc
					}
					t(it)
				} else {
					t(it)
					preconditional_C_line = last_C_line
				}
			}
			ancestors.remove(node)
		}
	}

	static def private dispatch void t(Object o) {
		throw new Exception("PrintCode unhandled object type: " + o.class)
	}
}
