#if 1
#if 1
typedef
#endif
        int gfp_t;
#endif
#if 1
_Bool irqs_disabled = 0;
#endif
#if 1
void local_irq_disable (
#if 1
                        void
#endif
                            )
{
    #if 1
    irqs_disabled = 1;
    #endif
}
#endif
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
static
#endif
       void __lockdep_trace_alloc (
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
                                   gfp_t gfp_mask
#endif
                                                 )
{
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
    if (! (gfp_mask & ((gfp_t) 0x10u))) return;
    #endif
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
    if (! (gfp_mask & ((gfp_t) 0x80u))) return;
    #endif
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
    assert (
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
            ! irqs_disabled
    #endif
                           );
    #endif
}
#endif
#if 1
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
void lockdep_trace_alloc (
#if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
                          gfp_t gfp_mask
#endif
                                        )
{
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
    __lockdep_trace_alloc (
    #if (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && (defined CONFIG_PROVE_LOCKING)
                           gfp_mask
    #endif
                                   );
    #endif
}
#elif !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
void lockdep_trace_alloc (
#if !(defined CONFIG_LOCKDEP) || (defined CONFIG_LOCKDEP) && !(defined CONFIG_TRACE_IRQFLAGS) || (defined CONFIG_LOCKDEP) && (defined CONFIG_TRACE_IRQFLAGS) && !(defined CONFIG_PROVE_LOCKING)
                          gfp_t gfp_mask
#endif
                                        )
{
}
#endif
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
void __cache_alloc_node (
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                         gfp_t flags
#endif
                                    )
{
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
    lockdep_trace_alloc (
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                         flags
    #endif
                              );
    #endif
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
void kmem_cache_alloc_node (
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                            gfp_t flags
#endif
                                       )
{
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
    __cache_alloc_node (
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                        flags
    #endif
                             );
    #endif
}
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
void kmem_cache_alloc_node_notrace (
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
                                    gfp_t flags
#endif
                                               )
{
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
    __cache_alloc_node (
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && (defined CONFIG_KMEMTRACE)
                        flags
    #endif
                             );
    #endif
}
#elif (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
void kmem_cache_alloc_node_notrace (
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
                                    gfp_t flags
#endif
                                               )
{
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
    kmem_cache_alloc_node (
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA) && !(defined CONFIG_KMEMTRACE)
                           flags
    #endif
                                );
    #endif
}
#endif
#endif
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
static
#endif
       void kmalloc_node (
#if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                          gfp_t gfp_mask
#endif
                                        )
{
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
    kmem_cache_alloc_node_notrace (
    #if (defined CONFIG_SLAB) && (defined CONFIG_NUMA)
                                   gfp_mask
    #endif
                                           );
    #endif
}
#endif
#if (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
void kmalloc_node ()
{
    #if (defined CONFIG_SLAB) && !(defined CONFIG_NUMA)
    return;
    #endif
}
#endif
#if (defined CONFIG_SLAB)
#if (defined CONFIG_SLAB)
static
#endif
       int setup_cpu_cache ()
{
    #if (defined CONFIG_SLAB)
    kmalloc_node (
    #if (defined CONFIG_SLAB)
                  (((gfp_t) 0x10u) | ((gfp_t) 0x40u) | ((gfp_t) 0x80u))
    #endif
                                                                       );
    #endif
}
#endif
#if (defined CONFIG_SLAB)
void kmem_cache_create ()
{
    #if (defined CONFIG_SLAB)
    setup_cpu_cache ();
    #endif
}
#endif
#if 1
#if (defined CONFIG_SLAB)
void kmem_cache_init (
#if (defined CONFIG_SLAB)
                      void
#endif
                          )
{
    #if (defined CONFIG_SLAB)
    kmem_cache_create ();
    #endif
}
#elif !(defined CONFIG_SLAB)
void kmem_cache_init (
#if !(defined CONFIG_SLAB)
                      void
#endif
                          )
{
}
#endif
#endif
#if 1
#if 1
static
#endif
       void mm_init (
#if 1
                     void
#endif
                         )
{
    #if 1
    kmem_cache_init ();
    #endif
}
#endif
#if 1
int main ()
{
    #if 1
    local_irq_disable ();
    #endif
    #if 1
    mm_init ();
    #endif
    #if 1
    return 0;
    #endif
}
#endif
