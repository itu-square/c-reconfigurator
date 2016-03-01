typedef int gfp_t;
_Bool irqs_disabled = 0;
void local_irq_disable (void)
{
    irqs_disabled = 1;
}
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
static void __lockdep_trace_alloc (gfp_t gfp_mask)
{
    if (!(gfp_mask & ((gfp_t) 0x10u))) return;
    if (!(gfp_mask & ((gfp_t) 0x80u))) return;
    assert (!irqs_disabled);
}
#endif
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
void lockdep_trace_alloc (gfp_t gfp_mask)
{
    __lockdep_trace_alloc (gfp_mask);
}
#endif
#if !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
void lockdep_trace_alloc (gfp_t gfp_mask)
{
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
void __cache_alloc_node (gfp_t flags)
{
    lockdep_trace_alloc (flags);
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
void kmem_cache_alloc_node (gfp_t flags)
{
    __cache_alloc_node (flags);
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
void kmem_cache_alloc_node_notrace (gfp_t flags)
{
    __cache_alloc_node (flags);
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
void kmem_cache_alloc_node_notrace (gfp_t flags)
{
    kmem_cache_alloc_node (flags);
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
static void kmalloc_node (gfp_t gfp_mask)
{
    kmem_cache_alloc_node_notrace (gfp_mask);
}
#endif
#if (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
void kmalloc_node ()
{
    return;
}
#endif
#if (defined CONFIG_SLAB)
static int setup_cpu_cache ()
{
    kmalloc_node ((((gfp_t) 0x10u) | ((gfp_t) 0x40u) | ((gfp_t) 0x80u)));
}
#endif
#if (defined CONFIG_SLAB)
void kmem_cache_create ()
{
    setup_cpu_cache ();
}
#endif
#if (defined CONFIG_SLAB)
void kmem_cache_init (void)
{
    kmem_cache_create ();
}
#endif
#if !(defined CONFIG_SLAB)
void kmem_cache_init (void)
{
}
#endif
static void mm_init (void)
{
    kmem_cache_init ();
}
int main ()
{
    local_irq_disable ();
    mm_init ();
    return (_recon_smth ? 1 : 0);
}