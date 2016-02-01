|- TranslationUnit
   |- ExternalDeclarationList
      |- Declaration
      |  |- DeclaringList
      |  |  |- BasicDeclarationSpecifier
      |  |  |  |- DeclarationQualifierList
      |  |  |  |  |- typedef
      |  |  |  |- int
      |  |  |- SimpleDeclarator
      |  |     |- gfp_t
      |  |- ;
      |- Declaration
      |  |- DeclaringList
      |  |  |- _Bool
      |  |  |- SimpleDeclarator
      |  |  |  |- irqs_disabled
      |  |  |- InitializerOpt
      |  |     |- =
      |  |     |- Initializer
      |  |        |- 0
      |  |- ;
      |- FunctionDefinition
      |  |- FunctionPrototype
      |  |  |- void
      |  |  |- FunctionDeclarator
      |  |     |- SimpleDeclarator
      |  |     |  |- local_irq_disable
      |  |     |- PostfixingFunctionDeclarator
      |  |        |- (
      |  |        |- ParameterTypeListOpt
      |  |        |  |- ParameterTypeList
      |  |        |     |- ParameterList
      |  |        |        |- ParameterDeclaration
      |  |        |           |- void
      |  |        |- )
      |  |- {
      |  |- CompoundStatement
      |  |  |- DeclarationOrStatementList
      |  |     |- ExpressionStatement
      |  |        |- AssignmentExpression
      |  |        |  |- PrimaryIdentifier
      |  |        |  |  |- irqs_disabled
      |  |        |  |- AssignmentOperator
      |  |        |  |  |- =
      |  |        |  |- 1
      |  |        |- ;
      |  |- }
      |- Conditional
      |  |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- BasicDeclarationSpecifier
      |     |  |  |- DeclarationQualifierList
      |     |  |  |  |- Conditional
      |     |  |  |     |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |  |  |     |- static
      |     |  |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- __lockdep_trace_alloc
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- TypedefTypeSpecifier
      |     |        |              |  |- gfp_t
      |     |        |              |- SimpleDeclarator
      |     |        |                 |- gfp_mask
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |     |  |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |     |  |- SelectionStatement
      |     |     |     |- if
      |     |     |     |- (
      |     |     |     |- UnaryExpression
      |     |     |     |  |- Unaryoperator
      |     |     |     |  |  |- !
      |     |     |     |  |- PrimaryExpression
      |     |     |     |     |- (
      |     |     |     |     |- AndExpression
      |     |     |     |     |  |- PrimaryIdentifier
      |     |     |     |     |  |  |- gfp_mask
      |     |     |     |     |  |- &
      |     |     |     |     |  |- PrimaryExpression
      |     |     |     |     |     |- (
      |     |     |     |     |     |- CastExpression
      |     |     |     |     |     |  |- (
      |     |     |     |     |     |  |- TypeName
      |     |     |     |     |     |  |  |- TypedefTypeSpecifier
      |     |     |     |     |     |  |     |- gfp_t
      |     |     |     |     |     |  |- )
      |     |     |     |     |     |  |- 0x10u
      |     |     |     |     |     |- )
      |     |     |     |     |- )
      |     |     |     |- )
      |     |     |     |- ReturnStatement
      |     |     |        |- return
      |     |     |        |- ;
      |     |     |- Conditional
      |     |     |  |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |     |  |- SelectionStatement
      |     |     |     |- if
      |     |     |     |- (
      |     |     |     |- UnaryExpression
      |     |     |     |  |- Unaryoperator
      |     |     |     |  |  |- !
      |     |     |     |  |- PrimaryExpression
      |     |     |     |     |- (
      |     |     |     |     |- AndExpression
      |     |     |     |     |  |- PrimaryIdentifier
      |     |     |     |     |  |  |- gfp_mask
      |     |     |     |     |  |- &
      |     |     |     |     |  |- PrimaryExpression
      |     |     |     |     |     |- (
      |     |     |     |     |     |- CastExpression
      |     |     |     |     |     |  |- (
      |     |     |     |     |     |  |- TypeName
      |     |     |     |     |     |  |  |- TypedefTypeSpecifier
      |     |     |     |     |     |  |     |- gfp_t
      |     |     |     |     |     |  |- )
      |     |     |     |     |     |  |- 0x80u
      |     |     |     |     |     |- )
      |     |     |     |     |- )
      |     |     |     |- )
      |     |     |     |- ReturnStatement
      |     |     |        |- return
      |     |     |        |- ;
      |     |     |- Conditional
      |     |        |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- assert
      |     |           |  |- (
      |     |           |  |- ExpressionList
      |     |           |  |  |- Conditional
      |     |           |  |     |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |     |           |  |     |- UnaryExpression
      |     |           |  |        |- Unaryoperator
      |     |           |  |        |  |- !
      |     |           |  |        |- PrimaryIdentifier
      |     |           |  |           |- irqs_disabled
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |  |- FunctionDefinition
      |  |  |- FunctionPrototype
      |  |  |  |- void
      |  |  |  |- FunctionDeclarator
      |  |  |     |- SimpleDeclarator
      |  |  |     |  |- lockdep_trace_alloc
      |  |  |     |- PostfixingFunctionDeclarator
      |  |  |        |- (
      |  |  |        |- ParameterTypeListOpt
      |  |  |        |  |- ParameterTypeList
      |  |  |        |     |- ParameterList
      |  |  |        |        |- Conditional
      |  |  |        |           |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |  |  |        |           |- ParameterDeclaration
      |  |  |        |              |- TypedefTypeSpecifier
      |  |  |        |              |  |- gfp_t
      |  |  |        |              |- SimpleDeclarator
      |  |  |        |                 |- gfp_mask
      |  |  |        |- )
      |  |  |- {
      |  |  |- CompoundStatement
      |  |  |  |- DeclarationOrStatementList
      |  |  |     |- Conditional
      |  |  |        |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |  |  |        |- ExpressionStatement
      |  |  |           |- FunctionCall
      |  |  |           |  |- PrimaryIdentifier
      |  |  |           |  |  |- __lockdep_trace_alloc
      |  |  |           |  |- (
      |  |  |           |  |- ExpressionList
      |  |  |           |  |  |- Conditional
      |  |  |           |  |     |- (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
      |  |  |           |  |     |- PrimaryIdentifier
      |  |  |           |  |        |- gfp_mask
      |  |  |           |  |- )
      |  |  |           |- ;
      |  |  |- }
      |  |- !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- lockdep_trace_alloc
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- TypedefTypeSpecifier
      |     |        |              |  |- gfp_t
      |     |        |              |- SimpleDeclarator
      |     |        |                 |- gfp_mask
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- __cache_alloc_node
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- TypedefTypeSpecifier
      |     |        |              |  |- gfp_t
      |     |        |              |- SimpleDeclarator
      |     |        |                 |- flags
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- lockdep_trace_alloc
      |     |           |  |- (
      |     |           |  |- ExpressionList
      |     |           |  |  |- Conditional
      |     |           |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |           |  |     |- PrimaryIdentifier
      |     |           |  |        |- flags
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- kmem_cache_alloc_node
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- TypedefTypeSpecifier
      |     |        |              |  |- gfp_t
      |     |        |              |- SimpleDeclarator
      |     |        |                 |- flags
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- __cache_alloc_node
      |     |           |  |- (
      |     |           |  |- ExpressionList
      |     |           |  |  |- Conditional
      |     |           |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |           |  |     |- PrimaryIdentifier
      |     |           |  |        |- flags
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |  |- Conditional
      |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
      |     |- FunctionDefinition
      |     |  |- FunctionPrototype
      |     |  |  |- void
      |     |  |  |- FunctionDeclarator
      |     |  |     |- SimpleDeclarator
      |     |  |     |  |- kmem_cache_alloc_node_notrace
      |     |  |     |- PostfixingFunctionDeclarator
      |     |  |        |- (
      |     |  |        |- ParameterTypeListOpt
      |     |  |        |  |- ParameterTypeList
      |     |  |        |     |- ParameterList
      |     |  |        |        |- Conditional
      |     |  |        |           |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
      |     |  |        |           |- ParameterDeclaration
      |     |  |        |              |- TypedefTypeSpecifier
      |     |  |        |              |  |- gfp_t
      |     |  |        |              |- SimpleDeclarator
      |     |  |        |                 |- flags
      |     |  |        |- )
      |     |  |- {
      |     |  |- CompoundStatement
      |     |  |  |- DeclarationOrStatementList
      |     |  |     |- Conditional
      |     |  |        |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
      |     |  |        |- ExpressionStatement
      |     |  |           |- FunctionCall
      |     |  |           |  |- PrimaryIdentifier
      |     |  |           |  |  |- __cache_alloc_node
      |     |  |           |  |- (
      |     |  |           |  |- ExpressionList
      |     |  |           |  |  |- Conditional
      |     |  |           |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
      |     |  |           |  |     |- PrimaryIdentifier
      |     |  |           |  |        |- flags
      |     |  |           |  |- )
      |     |  |           |- ;
      |     |  |- }
      |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
      |     |- FunctionDefinition
      |        |- FunctionPrototype
      |        |  |- void
      |        |  |- FunctionDeclarator
      |        |     |- SimpleDeclarator
      |        |     |  |- kmem_cache_alloc_node_notrace
      |        |     |- PostfixingFunctionDeclarator
      |        |        |- (
      |        |        |- ParameterTypeListOpt
      |        |        |  |- ParameterTypeList
      |        |        |     |- ParameterList
      |        |        |        |- Conditional
      |        |        |           |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
      |        |        |           |- ParameterDeclaration
      |        |        |              |- TypedefTypeSpecifier
      |        |        |              |  |- gfp_t
      |        |        |              |- SimpleDeclarator
      |        |        |                 |- flags
      |        |        |- )
      |        |- {
      |        |- CompoundStatement
      |        |  |- DeclarationOrStatementList
      |        |     |- Conditional
      |        |        |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
      |        |        |- ExpressionStatement
      |        |           |- FunctionCall
      |        |           |  |- PrimaryIdentifier
      |        |           |  |  |- kmem_cache_alloc_node
      |        |           |  |- (
      |        |           |  |- ExpressionList
      |        |           |  |  |- Conditional
      |        |           |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
      |        |           |  |     |- PrimaryIdentifier
      |        |           |  |        |- flags
      |        |           |  |- )
      |        |           |- ;
      |        |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- BasicDeclarationSpecifier
      |     |  |  |- DeclarationQualifierList
      |     |  |  |  |- Conditional
      |     |  |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |  |  |     |- static
      |     |  |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- kmalloc_node
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- TypedefTypeSpecifier
      |     |        |              |  |- gfp_t
      |     |        |              |- SimpleDeclarator
      |     |        |                 |- gfp_mask
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- kmem_cache_alloc_node_notrace
      |     |           |  |- (
      |     |           |  |- ExpressionList
      |     |           |  |  |- Conditional
      |     |           |  |     |- (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
      |     |           |  |     |- PrimaryIdentifier
      |     |           |  |        |- gfp_mask
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- kmalloc_node
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
      |     |        |- ReturnStatement
      |     |           |- return
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- BasicDeclarationSpecifier
      |     |  |  |- DeclarationQualifierList
      |     |  |  |  |- Conditional
      |     |  |  |     |- (defined CONFIG_SLAB)
      |     |  |  |     |- static
      |     |  |  |- int
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- setup_cpu_cache
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- kmalloc_node
      |     |           |  |- (
      |     |           |  |- ExpressionList
      |     |           |  |  |- Conditional
      |     |           |  |     |- (defined CONFIG_SLAB)
      |     |           |  |     |- PrimaryExpression
      |     |           |  |        |- (
      |     |           |  |        |- InclusiveOrExpression
      |     |           |  |        |  |- InclusiveOrExpression
      |     |           |  |        |  |  |- PrimaryExpression
      |     |           |  |        |  |  |  |- (
      |     |           |  |        |  |  |  |- CastExpression
      |     |           |  |        |  |  |  |  |- (
      |     |           |  |        |  |  |  |  |- TypeName
      |     |           |  |        |  |  |  |  |  |- TypedefTypeSpecifier
      |     |           |  |        |  |  |  |  |     |- gfp_t
      |     |           |  |        |  |  |  |  |- )
      |     |           |  |        |  |  |  |  |- 0x10u
      |     |           |  |        |  |  |  |- )
      |     |           |  |        |  |  |- |
      |     |           |  |        |  |  |- PrimaryExpression
      |     |           |  |        |  |     |- (
      |     |           |  |        |  |     |- CastExpression
      |     |           |  |        |  |     |  |- (
      |     |           |  |        |  |     |  |- TypeName
      |     |           |  |        |  |     |  |  |- TypedefTypeSpecifier
      |     |           |  |        |  |     |  |     |- gfp_t
      |     |           |  |        |  |     |  |- )
      |     |           |  |        |  |     |  |- 0x40u
      |     |           |  |        |  |     |- )
      |     |           |  |        |  |- |
      |     |           |  |        |  |- PrimaryExpression
      |     |           |  |        |     |- (
      |     |           |  |        |     |- CastExpression
      |     |           |  |        |     |  |- (
      |     |           |  |        |     |  |- TypeName
      |     |           |  |        |     |  |  |- TypedefTypeSpecifier
      |     |           |  |        |     |  |     |- gfp_t
      |     |           |  |        |     |  |- )
      |     |           |  |        |     |  |- 0x80u
      |     |           |  |        |     |- )
      |     |           |  |        |- )
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- kmem_cache_create
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |     |- Conditional
      |     |        |- (defined CONFIG_SLAB)
      |     |        |- ExpressionStatement
      |     |           |- FunctionCall
      |     |           |  |- PrimaryIdentifier
      |     |           |  |  |- setup_cpu_cache
      |     |           |  |- (
      |     |           |  |- )
      |     |           |- ;
      |     |- }
      |- Conditional
      |  |- (defined CONFIG_SLAB)
      |  |- FunctionDefinition
      |  |  |- FunctionPrototype
      |  |  |  |- void
      |  |  |  |- FunctionDeclarator
      |  |  |     |- SimpleDeclarator
      |  |  |     |  |- kmem_cache_init
      |  |  |     |- PostfixingFunctionDeclarator
      |  |  |        |- (
      |  |  |        |- ParameterTypeListOpt
      |  |  |        |  |- ParameterTypeList
      |  |  |        |     |- ParameterList
      |  |  |        |        |- Conditional
      |  |  |        |           |- (defined CONFIG_SLAB)
      |  |  |        |           |- ParameterDeclaration
      |  |  |        |              |- void
      |  |  |        |- )
      |  |  |- {
      |  |  |- CompoundStatement
      |  |  |  |- DeclarationOrStatementList
      |  |  |     |- Conditional
      |  |  |        |- (defined CONFIG_SLAB)
      |  |  |        |- ExpressionStatement
      |  |  |           |- FunctionCall
      |  |  |           |  |- PrimaryIdentifier
      |  |  |           |  |  |- kmem_cache_create
      |  |  |           |  |- (
      |  |  |           |  |- )
      |  |  |           |- ;
      |  |  |- }
      |  |- !(defined CONFIG_SLAB)
      |  |- FunctionDefinition
      |     |- FunctionPrototype
      |     |  |- void
      |     |  |- FunctionDeclarator
      |     |     |- SimpleDeclarator
      |     |     |  |- kmem_cache_init
      |     |     |- PostfixingFunctionDeclarator
      |     |        |- (
      |     |        |- ParameterTypeListOpt
      |     |        |  |- ParameterTypeList
      |     |        |     |- ParameterList
      |     |        |        |- Conditional
      |     |        |           |- !(defined CONFIG_SLAB)
      |     |        |           |- ParameterDeclaration
      |     |        |              |- void
      |     |        |- )
      |     |- {
      |     |- CompoundStatement
      |     |  |- DeclarationOrStatementList
      |     |- }
      |- FunctionDefinition
      |  |- FunctionPrototype
      |  |  |- BasicDeclarationSpecifier
      |  |  |  |- DeclarationQualifierList
      |  |  |  |  |- static
      |  |  |  |- void
      |  |  |- FunctionDeclarator
      |  |     |- SimpleDeclarator
      |  |     |  |- mm_init
      |  |     |- PostfixingFunctionDeclarator
      |  |        |- (
      |  |        |- ParameterTypeListOpt
      |  |        |  |- ParameterTypeList
      |  |        |     |- ParameterList
      |  |        |        |- ParameterDeclaration
      |  |        |           |- void
      |  |        |- )
      |  |- {
      |  |- CompoundStatement
      |  |  |- DeclarationOrStatementList
      |  |     |- ExpressionStatement
      |  |        |- FunctionCall
      |  |        |  |- PrimaryIdentifier
      |  |        |  |  |- kmem_cache_init
      |  |        |  |- (
      |  |        |  |- )
      |  |        |- ;
      |  |- }
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
         |- CompoundStatement
         |  |- DeclarationOrStatementList
         |     |- ExpressionStatement
         |     |  |- FunctionCall
         |     |  |  |- PrimaryIdentifier
         |     |  |  |  |- local_irq_disable
         |     |  |  |- (
         |     |  |  |- )
         |     |  |- ;
         |     |- ExpressionStatement
         |     |  |- FunctionCall
         |     |  |  |- PrimaryIdentifier
         |     |  |  |  |- mm_init
         |     |  |  |- (
         |     |  |  |- )
         |     |  |- ;
         |     |- ReturnStatement
         |        |- return
         |        |- 0
         |        |- ;
         |- }
