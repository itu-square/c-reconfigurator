typedef int gfp_t;
_Bool irqs_disabled = 0;
void local_irq_disable (void)
{
    irqs_disabled = 1;
}
static void __lockdep_trace_alloc_V0 (gfp_t gfp_mask)
{
    if (!(gfp_mask & ((gfp_t) 0x10u))) return;
    if (!(gfp_mask & ((gfp_t) 0x80u))) return;
    assert (!irqs_disabled);
}
void lockdep_trace_alloc_V0 (gfp_t gfp_mask)
{
    __lockdep_trace_alloc (gfp_mask);
}
void lockdep_trace_alloc_V1 (gfp_t gfp_mask)
{
}
void __cache_alloc_node_V2 (gfp_t flags)
{
    lockdep_trace_alloc (flags);
}
void kmem_cache_alloc_node_V2 (gfp_t flags)
{
    __cache_alloc_node (flags);
}
void kmem_cache_alloc_node_notrace_V3 (gfp_t flags)
{
    __cache_alloc_node (flags);
}
void kmem_cache_alloc_node_notrace_V4 (gfp_t flags)
{
    kmem_cache_alloc_node (flags);
}
static void kmalloc_node_V2 (gfp_t gfp_mask)
{
    kmem_cache_alloc_node_notrace (gfp_mask);
}
void kmalloc_node_V5 ()
{
    return;
}
static int setup_cpu_cache_V6 ()
{
    kmalloc_node ((((gfp_t) 0x10u) | ((gfp_t) 0x40u) | ((gfp_t) 0x80u)));
}
void kmem_cache_create_V6 ()
{
    setup_cpu_cache ();
}
void kmem_cache_init_V6 (void)
{
    kmem_cache_create ();
}
void kmem_cache_init_V7 (void)
{
}
static void mm_init (void)
{
    kmem_cache_init ();
}
int main ()
{
    local_irq_disable ();
    mm_init ();
    return 0;
}