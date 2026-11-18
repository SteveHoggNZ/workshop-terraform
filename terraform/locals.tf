locals {
  location_short = {
    australiaeast      = "aue"
    australiasoutheast = "aus"
  }[var.location]

  env_short = substr(var.environment, 0, 1)
  instance  = format("%03d", var.instance)

  # Pattern: <type>-<name>-<env>-<region>-<nnn>
  suffix = "${var.environment}-${local.location_short}-${local.instance}"

  names = {
    resource_group  = "rg-${var.workload}-${local.suffix}"
    virtual_network = "vnet-${var.workload}-${local.suffix}"
    subnets         = { for tier, _ in var.tiers : tier => "snet-${tier}-${local.suffix}" }
    nsgs            = { for tier, _ in var.tiers : tier => "nsg-${tier}-${local.suffix}" }
    load_balancers  = { for tier, _ in var.tiers : tier => "lbi-${tier}-${local.suffix}" }
    # Windows computer names are limited to 15 characters: vm<tier><e><region><nn>
    vms = {
      for tier, t in var.tiers : tier => [
        for i in range(1, t.vm_count + 1) : format("vm%s%s%s%02d", tier, local.env_short, local.location_short, i)
      ]
    }
  }

  tags = merge(var.tags, {
    supported-by = "cloud-team"
    environment  = var.environment
    workload     = var.workload
    managed-by   = "terraform"
  })
}
