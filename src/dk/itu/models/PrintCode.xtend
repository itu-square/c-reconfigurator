package dk.itu.models

import java.util.ArrayList
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node

import static extension dk.itu.models.Extensions.*

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
			output.print(''' «condition.PCtoCPPexp»''')
			current_line += ''' «condition.PCtoCPPexp»'''
		} else {
			output.println
			output.print(indent)
			output.print(last_C_line.replaceAll(".", " "))
			output.print('''#elif «condition.PCtoCPPexp»''')
			current_line = '''#elif «condition.PCtoCPPexp»'''
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
		
		if (
			last_line.endsWith(";") || last_line.endsWith("{") || last_line.endsWith("}")
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
		
		if (last_line.startsWith("#") && !last_line.equals("#endif")) {
			output.print(current_C_line.replaceAll(".", " "))
 		}

		if (
			!last_C_line.isEmpty
			&& !last_C_line.endsWith("(") && !last_C_line.endsWith(";") && !last_C_line.endsWith("{") && !last_C_line.endsWith("!") && !last_line.endsWith("}")
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
		
		var PresenceCondition lastPC
		
		var preconditional_C_line = last_C_line
		var current_C_line = last_C_line
		var current_line = last_line
		
		if(
			#["Declaration", "FunctionDefinition"].contains(node.name)
			&& !ancestors.exists[c | c instanceof GNode && c.name.equals("FunctionDefinition")]
			&& !last_line.startsWith("#") && !last_line.empty
		) {
			output.println
			current_C_line = ""
			current_line = ""
		}
		
		if(
			#["Declaration", "FunctionDefinition"].contains(node.name)
			&& node.properties != null && node.hasProperty("OriginalPC")
		) {
			output.println
			output.print('''// «(node.getProperty("OriginalPC") as PresenceCondition).PCtoCPPexp»''')
			if(last_line.empty)
				output.println
		}
			
		if(
			ancestors.last != null
			&& ancestors.last.name.equals("SelectionStatement")
			&& ancestors.last.indexOf(node) > 0
			&& ancestors.last.get(ancestors.last.indexOf(node)-1) instanceof Language
			&& ((ancestors.last.get(ancestors.last.indexOf(node)-1) as Language<CTag>).tag.equals(CTag::RPAREN)
				|| (ancestors.last.get(ancestors.last.indexOf(node)-1) as Language<CTag>).tag.equals(CTag::^ELSE))
			&& #["ExpressionStatement", "ReturnStatement"].contains(node.name)
		) {
			output.println
			output.print("        ")
			current_C_line = "        "
			current_line = "        "
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
				if (it instanceof PresenceCondition) {
					if (lastPC == null) {
						lastPC = it
					} else if (lastPC.isMutuallyExclusive(it)) {
						lastPC = lastPC.or(it)
						last_C_line = preconditional_C_line
					} else {
						lastPC = it
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

		} else if (
			node.name.equals("Declaration")
			
			&& node.get(0) instanceof GNode
			&& (node.get(0) as GNode).name.equals("DeclaringList")
			
			&& (node.get(0) as GNode).get(0).toString.equals("char")
			
			&& (node.get(0) as GNode).get(1) instanceof GNode
			&& ((node.get(0) as GNode).get(1) as GNode).name.equals("ArrayDeclarator")
			&& ((node.get(0) as GNode).get(1) as GNode).get(0) instanceof GNode
			&& (((node.get(0) as GNode).get(1) as GNode).get(0) as GNode).name.equals("SimpleDeclarator")
			&& (((node.get(0) as GNode).get(1) as GNode).get(0) as GNode).get(0).toString.equals("include")
			
			&& (node.get(0) as GNode).get(2) instanceof GNode
			&& ((node.get(0) as GNode).get(2) as GNode).name.equals("InitializerOpt")
			&& ((node.get(0) as GNode).get(2) as GNode).get(1) instanceof GNode
			&& (((node.get(0) as GNode).get(2) as GNode).get(1) as GNode).name.equals("Initializer")
			
			&& (((node.get(0) as GNode).get(2) as GNode).get(1) as GNode)
				.get(0) instanceof GNode
			&& ((((node.get(0) as GNode).get(2) as GNode).get(1) as GNode)
				.get(0) as GNode).name.equals("StringLiteralList")
			&& ((((node.get(0) as GNode).get(2) as GNode).get(1) as GNode)
				.get(0) as GNode).get(0).toString.startsWith("\"#include")
		) {
			var includeStrLit = ((((node.get(0) as GNode).get(2) as GNode).get(1) as GNode)
				.get(0) as GNode).get(0).toString
			includeStrLit = includeStrLit.subSequence(1, includeStrLit.length-1).toString
			
			output.println(includeStrLit)
			last_line = includeStrLit
		} else {
			ancestors.add(node)
			for (Object it : node) {
				if (
					it instanceof GNode
					&& (it as GNode).name.equals("Conditional")
					&& (it as GNode).filter(PresenceCondition).size == 1
				) {
					val pc = (it as GNode).get(0) as PresenceCondition
					if (lastPC == null) {
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
}
