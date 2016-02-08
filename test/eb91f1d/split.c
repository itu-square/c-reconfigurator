typedef int gfp_t;
_Bool irqs_disabled = 0;
void local_irq_disable (void)
{
    irqs_disabled = 1;
}
void lockdep_trace_alloc (gfp_t gfp_mask)
{
    __lockdep_trace_alloc (gfp_mask);
}
static void __lockdep_trace_alloc (gfp_t gfp_mask)
{
    if (! (gfp_mask & ((gfp_t) 0x10u))) return;
    if (! (gfp_mask & ((gfp_t) 0x80u))) return;
    assert (! irqs_disabled);
}
#elif (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
#endif
void lockdep_trace_alloc (gfp_t gfp_mask)
{
}
#elif !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
#endif
static void kmalloc_node (gfp_t gfp_mask)
{
    kmem_cache_alloc_node_notrace (gfp_mask);
}
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
void kmem_cache_alloc_node_notrace (gfp_t flags)
{
    __cache_alloc_node (flags);
}
#else
void kmem_cache_alloc_node_notrace (gfp_t flags)
{
    kmem_cache_alloc_node (flags);
}
#endif
void kmem_cache_alloc_node (gfp_t flags)
{
    __cache_alloc_node (flags);
}
void __cache_alloc_node (gfp_t flags)
{
    lockdep_trace_alloc (flags);
}
#elif (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
#endif
void kmalloc_node ()
{
    return;
}
#elif (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
#endif
void kmem_cache_init (void)
{
    kmem_cache_create ();
}
void kmem_cache_create ()
{
    setup_cpu_cache ();
}
static int setup_cpu_cache ()
{
    kmalloc_node ((((gfp_t) 0x10u) | ((gfp_t) 0x40u) | ((gfp_t) 0x80u)));
}
#elif (defined CONFIG_SLAB)
#endif
void kmem_cache_init (void)
{
}
#elif !(defined CONFIG_SLAB)
#endif
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