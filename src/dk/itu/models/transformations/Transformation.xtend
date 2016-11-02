package dk.itu.models.transformations

import xtc.tree.Node

abstract class Transformation {
	
	def Node transform(Node node)

}