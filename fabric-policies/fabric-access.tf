/* This Terraform plan configures and applies interface policies and
all policies associated with it. The requirements were as follows:

Create a static VLAN pool (TF-VLAN-POOL) using the aci_vlan_pool resource.
Create a VLAN pool range using the aci_ranges resource
Create a Physical domain (tf-domain) using aci_physical_domain
Create an AAEP (tf_aaep) using aci_attachable_access_entity_profile
Create a Leaf Interface Profile (leaf101_intprof) with aci_leaf_interface_profile
An Access Port Selector (tf_port_selector) using aci_access_port_selector
A CDP (tf_cdp_pol), Link Level (tf_link_if_pol) and LLDP Policies (tf_lldp_pol) using aci_cdp_interface_policy, aci_fabric_if_pol, and
aci_lldp_interface_policy.
An access port policy group (tf_access_port) using aci_leaf_access_port_policy_group
An access port block (tf_port_block) for port 1/20 on leaf 1 using aci_access_port_block
A Leaf Switch Profile (leaf101_swprof) using aci_leaf_profile
*/

# Create the VLAN pool in Fabric policies. The pool is a static pool.
resource "aci_vlan_pool" "TF-VLAN-POOL" {
  name  = "TF-VLAN-POOL"
  description = "Created with Terraform"
  alloc_mode  = "static"
}

# Add VLAN Ranges to VLAN pool with static allocation. We are configuring a range from 121 to 130.
# The vlan_pool_dn is required to refer to the previous configured vlan pool
resource "aci_ranges" "example" {
  description = "Created with Terraform"
  vlan_pool_dn  = aci_vlan_pool.TF-VLAN-POOL.id
  from  = "vlan-121"
  to  = "vlan-130"
  alloc_mode = "static"
  role = "external"
}

# Create the Physical domain and associated it to the vlan pool
# This has a related to be previously created vlan pool and also
# uses the Meta-Argument to handle dependencies.
resource "aci_physical_domain" "PhyDom" {
  depends_on = [aci_vlan_pool.TF-VLAN-POOL]
  name  = "tf-domain"
  relation_infra_rs_vlan_ns = aci_vlan_pool.TF-VLAN-POOL.id
}

# Create the AAEP and map it to the Physical Domain above
resource "aci_attachable_access_entity_profile" "my_aaep" {
  name = "tf_aaep"
  description = "Created with Terraform"
  relation_infra_rs_dom_p  = [aci_physical_domain.PhyDom.id]
}

# Create the leaf interface profile
resource "aci_leaf_interface_profile" "tf_leaf_profile" {
  name = "leaf101_intprof"
  description = "Created with Terraform"
}

# Create the access port selector. The leaf_interface_profile_dn is required in this resource.
# It also requires that the relation to the access port policy group be listed as well.
resource "aci_access_port_selector" "test_selector" {
  leaf_interface_profile_dn = aci_leaf_interface_profile.tf_leaf_profile.id
  name = "tf_port_selector"
  description = "Created with Terraform"
  access_port_selector_type = "range"
  relation_infra_rs_acc_base_grp = aci_leaf_access_port_policy_group.tf_leaf_acc_port_pol_grp.id
}

/*
# Create an LACP policy. Not actually using this since we're not using Port Channels/vPCs
# But this configuration does work
resource "aci_lacp_policy" "tf_lacp_int_policy" {
  description = "Created with Terraform"
  name        = "tf_lacp_pol"
  ctrl        = ["susp-individual", "load-defer", "graceful-conv"]
  max_links   = "16"
  min_links   = "1"
}
*/

# Create CDP interface policy and enable it
resource "aci_cdp_interface_policy" "tf_cdp_int_pol" {
  description = "Created with Terraform"
  name  = "tf_cdp_pol"
  admin_st  = "enabled"
}

# Create an LLDP interface policy and enable it
resource "aci_lldp_interface_policy" "tf_lldp_int_pol" {
  description = "Created with Terraform"
  name        = "tf_lldp_pol"
  admin_rx_st = "enabled"
  admin_tx_st = "enabled"
}

# Create a Link Level interface policy and set speed to 10G
resource "aci_fabric_if_pol" "tf_link_int_pol" {
  name        = "tf_link_pol"
  description = "Created with Terraform"
  speed       = "10G"
}

# Create an access port policy group. This also references relations to the CDP,
# LLDP, and AAEP polices that are also configured in this plan.
resource "aci_leaf_access_port_policy_group" "tf_leaf_acc_port_pol_grp" {
  description = "Created with Terraform"
  name        = "tf_access_port"
  relation_infra_rs_lldp_if_pol = aci_lldp_interface_policy.tf_lldp_int_pol.id
  relation_infra_rs_cdp_if_pol = aci_cdp_interface_policy.tf_cdp_int_pol.id
  relation_infra_rs_h_if_pol = aci_fabric_if_pol.tf_link_int_pol.id
  relation_infra_rs_att_ent_p = aci_attachable_access_entity_profile.my_aaep.id
}

# Create access port block for interface 1/20 tied to the access port selector.
# The access port selector DN is required and points to the access port selector.
resource "aci_access_port_block" "tf_access_port_block" {
  access_port_selector_dn = aci_access_port_selector.test_selector.id
  description = "Created with Terraform"
  name                    = "tf_port_block"
  from_card               = "1"
  from_port               = "20"
  to_card                 = "1"
  to_port                 = "20"
}

# Create a Leaf Switch Profile and add the leaf interface profile previously created.
# This has a relation to the aci leaf interface profile and as it's a "set of String",
# We are required to use the "[]".
resource "aci_leaf_profile" "leaf_prof" {
  name        = "leaf101_swprof"
  relation_infra_rs_acc_port_p = [aci_leaf_interface_profile.tf_leaf_profile.id]
  leaf_selector {
      description = "Modified with Terraform"
      name = "leaf101_swsel"
      switch_association_type = "range"
      node_block {
        name  = "blk1"
        from_ = "101"
        to_   = "101"
        }
  }
}