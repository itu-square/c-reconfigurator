package itu

import xtc.lang.cpp.PresenceConditionManager.PresenceCondition
import xtc.lang.cpp.Syntax.Language
import xtc.tree.GNode
import xtc.tree.Node
import java.util.List

interface Tx {
	def void tx_start(PresenceCondition condition, List<Node> ancestors)

	def void tx_end(PresenceCondition condition, List<Node> ancestors)

	def void tx_start(Language language, List<Node> ancestors)

	def void tx_end(Language language, List<Node> ancestors)

	def void tx_start(GNode node, List<Node> ancestors)

	def void tx_end(GNode node, List<Node> ancestors)

	def void tx_start(Node node, List<Node> ancestors)

	def void tx_end(Node node, List<Node> ancestors)

}
