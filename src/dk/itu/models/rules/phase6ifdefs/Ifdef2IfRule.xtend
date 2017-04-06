package dk.itu.models.rules.phase6ifdefs

import dk.itu.models.Reconfigurator
import dk.itu.models.rules.AncestorGuaranteedRule
import java.util.AbstractMap.SimpleEntry
import java.util.ArrayList
import org.eclipse.xtext.xbase.lib.Functions.Function1
import xtc.lang.cpp.CTag
import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.lang.cpp.Syntax.Text
import xtc.tree.GNode
import xtc.tree.Node
import xtc.util.Pair

import static extension dk.itu.models.Extensions.*
import dk.itu.models.Settings

class Ifdef2IfRule extends AncestorGuaranteedRule {
	
	override dispatch PresenceCondition transform(PresenceCondition cond) {
		cond
	}

	override dispatch Language<CTag> transform(Language<CTag> lang) {
		lang
	}

	override dispatch Pair<Object> transform(Pair<Object> pair) {
		pair
	}
	
	override dispatch Object transform(GNode node) {
		
		if (
			node.name.equals("Conditional")
			&& (
				#["AdditiveExpression", "Initializer", "ExpressionStatement", "ReturnStatement",
					"MultiplicativeExpression", "PrimaryExpression", "ConditionalExpression", "ShiftExpression",
					"RelationalExpression", "ExpressionList", "FunctionCall"].contains(ancestors.last.name)
				||
				(ancestors.last.name.equals("SelectionStatement")
					&& ancestors.last.indexOf(node) < ancestors.last.indexOf(ancestors.last.findFirst[it instanceof Language<?> && (it as Language<CTag>).tag.equals(CTag.RPAREN)]) )
				)
		) {
			//            List<     Map<        OriginalPC,        SimplifiedPC>>
			val pcs = new ArrayList<SimpleEntry<PresenceCondition, PresenceCondition>>
			
			var disPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			for (PresenceCondition pc : node.filter(PresenceCondition)) {
				val newPC = Reconfigurator::presenceConditionManager.newPresenceCondition(pc.BDD.constrain(disPC.BDD.not))
				pcs.add(new SimpleEntry(pc, newPC))
				disPC = disPC.or(pc)
			}
			
			var Node exp = null
			if (!node.presenceCondition.getBDD.imp(disPC.getBDD).isOne) {
				exp = GNode::create(
					"FunctionCall",
					GNode::create(
						"PrimaryIdentifier",
						new Text(CTag::IDENTIFIER, "_reconfig_skip")),
					new Language<CTag>(CTag::LPAREN),
					new Language<CTag>(CTag::RPAREN))
			}
			
			for (SimpleEntry<PresenceCondition, PresenceCondition> map : pcs.reverseView) {
				if (node.getChildrenGuardedBy(map.key).size != 1) {
					println('''- Ifdef2IfRule: PresenceCondition guarding multiple children.''')
					println('''- «node.getChildrenGuardedBy(map.key).size»''')
					node.getChildrenGuardedBy(map.key).forEach[println('''- «it»''')]
					println(node.printAST)
					throw new Exception("Ifdef2IfRule: PresenceCondition guarding multiple children.")
				}
				
				if (exp === null) { // and pc.isTrue because of previous check
					exp = node.getChildrenGuardedBy(map.key).get(0) as Node
				} else {
					exp = GNode::create("PrimaryExpression",
						new Language<CTag>(CTag.LPAREN),
				 		GNode::create("ConditionalExpression",
				 			map.value.PCtoCexp,
				 			new Language<CTag>(CTag.QUESTION),
				 			node.getChildrenGuardedBy(map.key).get(0),
				 			new Language<CTag>(CTag.COLON),
				 			exp
				 			),
				 		new Language<CTag>(CTag.RPAREN))
				}
			}
			return exp
		} else if (
			node.name.equals("Conditional")
			&& #["DeclarationOrStatementList", "CompoundStatement", "SelectionStatement",
				"LabeledStatement"].contains(ancestors.last.name)
		) {
			//            List<     Map<        OriginalPC,        SimplifiedPC>>
			val pcs = new ArrayList<SimpleEntry<PresenceCondition, PresenceCondition>>
			
			var disPC = Reconfigurator::presenceConditionManager.newPresenceCondition(false)
			for (PresenceCondition pc : node.filter(PresenceCondition)) {
				val newPC = Reconfigurator::presenceConditionManager.newPresenceCondition(pc.BDD.constrain(disPC.BDD.not))
				pcs.add(new SimpleEntry(pc, newPC))
				disPC = disPC.or(pc)
			}

			var GNode exp = null
			var GNode lastexp = null
			
			for (SimpleEntry<PresenceCondition, PresenceCondition> map : pcs) {
				
				val branchChildren = node.getChildrenGuardedBy(map.key)
				val useBraces = branchChildren.size > 1
					|| (
						branchChildren.get(0).is_GNode("SelectionStatement")
						|| branchChildren.get(0).is_GNode("IterationStatement")
					)
				val Function1<Node, Node> lbrace = [Node n | if (useBraces) n.add(new Language<CTag>(CTag::LBRACE)) else n]
				val Function1<Node, Node> rbrace = [Node n | if (useBraces) n.add(new Language<CTag>(CTag::RBRACE)) else n]
				
				
				if (map == pcs.head) {
					exp = GNode::create("SelectionStatement")
					exp = exp.add(new Language<CTag>(CTag::^IF))
						.add(new Language<CTag>(CTag::LPAREN))
						.add(map.value.PCtoCexp)
						.add(new Language<CTag>(CTag::RPAREN))
						.pipe(lbrace)
						.addAll(branchChildren)
						.pipe(rbrace).as_GNode
					lastexp = exp
				} else if (map != pcs.last) {
					var newexp = GNode::create("SelectionStatement")
					newexp = newexp.add(new Language<CTag>(CTag::^IF))
							.add(new Language<CTag>(CTag::LPAREN))
							.add(map.value.PCtoCexp)
							.add(new Language<CTag>(CTag::RPAREN))
							.pipe(lbrace)
							.addAll(branchChildren)
							.pipe(rbrace).as_GNode
					lastexp.add(new Language<CTag>(CTag::^ELSE))
					lastexp.add(newexp)
					lastexp = newexp
				} else { // map == pcs.last
					lastexp.add(new Language<CTag>(CTag::^ELSE))
						.pipe(lbrace)
						.addAll(branchChildren)
						.pipe(rbrace).as_GNode
				}
			}
			return exp
		} else if (
			node.name.equals("Conditional")
			&& ancestors.last.name.equals("ExternalDeclarationList")
			&& node.get(1).is_GNode("Declaration")
			&& node.get(1).as_GNode.get(0).is_GNode("DeclaringList")
			&& node.get(1).as_GNode.get(0).as_GNode.get(1).is_GNode("ArrayDeclarator")
			&& node.get(1).as_GNode.get(0).as_GNode.get(1).as_GNode.get(0).is_GNode("SimpleDeclarator")
			&& (node.get(1).as_GNode.get(0).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.equals(Settings::reconfiguratorIncludePlaceholder)
			 || node.get(1).as_GNode.get(0).as_GNode.get(1).as_GNode.get(0).as_GNode.get(0).toString.equals(Settings::reconfiguratorIncludePlaceholderEnd)
			 )
		) {
			return node
		} else if (
			node.name.equals("Conditional")
		) {
			println
			ancestors.forEach[
				println('''- «it.name»''')]
			println(node.printAST)
			throw new Exception("Ifdef2IfRule: unexpected Conditional context")
		}
		
		node
	}

}