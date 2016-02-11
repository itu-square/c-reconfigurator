|- TranslationUnit
   |- ExternalDeclarationList
      |- FunctionDefinition
         |- FunctionPrototype
         |  |- int
         |  |- FunctionDeclarator
         |     |- SimpleDeclarator
         |     |  |- main
         |     |- PostfixingFunctionDeclarator
         |        |- (
         |        |- )
         |- {
         |- Conditional
         |  |- (defined X) && !(defined Y)
         |  |- CompoundStatement
         |     |- DeclarationOrStatementList
         |        |- Conditional
         |           |- !(defined X) || (defined X) && (defined Y)
         |           |- Conditional
         |              |- (defined X) && (defined Y)
         |              |- ReturnStatement
         |              |  |- return
         |              |  |- 0
         |              |  |- ;
         |              |- !(defined X)
         |              |- ReturnStatement
         |                 |- return
         |                 |- UnaryExpression
         |                 |  |- Unaryoperator
         |                 |  |  |- -
         |                 |  |- 1
         |                 |- ;
         |  |- !(defined X) || (defined X) && (defined Y)
         |  |- CompoundStatement
         |     |- DeclarationOrStatementList
         |        |- Conditional
         |           |- !(defined X) || (defined X) && (defined Y)
         |           |- Conditional
         |              |- (defined X) && (defined Y)
         |              |- ReturnStatement
         |              |  |- return
         |              |  |- 0
         |              |  |- ;
         |              |- !(defined X)
         |              |- ReturnStatement
         |                 |- return
         |                 |- UnaryExpression
         |                 |  |- Unaryoperator
         |                 |  |  |- -
         |                 |  |- 1
         |                 |- ;
         |- }
