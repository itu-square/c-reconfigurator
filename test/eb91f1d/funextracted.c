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
    ((_reconfig_CONFIG_LOCKDEP && _reconfig_CONFIG_TRACE_IRQFLAGS && _reconfig_CONFIG_PROVE_LOCKING) ? __lockdep_trace_alloc_V0 : assert (0));
}
void lockdep_trace_alloc_V1 (gfp_t gfp_mask)
{
}
void __cache_alloc_node_V2 (gfp_t flags)
{
    ((_reconfig_CONFIG_LOCKDEP && _reconfig_CONFIG_TRACE_IRQFLAGS && _reconfig_CONFIG_PROVE_LOCKING) ? lockdep_trace_alloc_V0 : ((!_reconfig_CONFIG_LOCKDEP || _reconfig_CONFIG_LOCKDEP && !_reconfig_CONFIG_TRACE_IRQFLAGS || _reconfig_CONFIG_LOCKDEP && _reconfig_CONFIG_TRACE_IRQFLAGS && !_reconfig_CONFIG_PROVE_LOCKING) ? lockdep_trace_alloc_V1 : assert (0)));
}
void kmem_cache_alloc_node_V2 (gfp_t flags)
{
    ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA) ? __cache_alloc_node_V2 : assert (0));
}
void kmem_cache_alloc_node_notrace_V3 (gfp_t flags)
{
    ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA) ? __cache_alloc_node_V2 : assert (0));
}
void kmem_cache_alloc_node_notrace_V4 (gfp_t flags)
{
    ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA) ? kmem_cache_alloc_node_V2 : assert (0));
}
static void kmalloc_node_V2 (gfp_t gfp_mask)
{
    ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA && _reconfig_CONFIG_KMEMTRACE) ? kmem_cache_alloc_node_notrace_V3 : ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA && !_reconfig_CONFIG_KMEMTRACE) ? kmem_cache_alloc_node_notrace_V4 : assert (0)));
}
void kmalloc_node_V5 ()
{
    return;
}
static int setup_cpu_cache_V6 ()
{
    ((_reconfig_CONFIG_SLAB && _reconfig_CONFIG_NUMA) ? kmalloc_node_V2 : ((_reconfig_CONFIG_SLAB && !_reconfig_CONFIG_NUMA) ? kmalloc_node_V5 : assert (0)));
}
void kmem_cache_create_V6 ()
{
    ((_reconfig_CONFIG_SLAB) ? setup_cpu_cache_V6 : assert (0));
}
void kmem_cache_init_V6 (void)
{
    ((_reconfig_CONFIG_SLAB) ? kmem_cache_create_V6 : assert (0));
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
    return (_recon_smth ? 1 : 0);
}