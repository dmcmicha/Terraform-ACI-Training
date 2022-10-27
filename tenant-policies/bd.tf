/*
 Configures the Bridge Domains and Bridge Domains Subnets.
*/
resource "aci_bridge_domain" "web-bd" {
 tenant_dn = aci_tenant.terraform_tenant.id
 relation_fv_rs_ctx = aci_vrf.terraform_vrf.id
 name = var.bd_name[0]
 description = "Created with Terraform"
}
resource "aci_subnet" "web_subnet" {
 parent_dn = aci_bridge_domain.web-bd.id
 ip = "10.1.1.1/24"
}
resource "aci_bridge_domain" "app-bd" {
 tenant_dn = aci_tenant.terraform_tenant.id
 relation_fv_rs_ctx = aci_vrf.terraform_vrf.id
 name = var.bd_name[1]
 description = "Created with Terraform"
}
resource "aci_subnet" "app_subnet" {
 parent_dn = aci_bridge_domain.app-bd.id
 ip = "10.1.2.1/24"
}
resource "aci_bridge_domain" "db-bd" {
 tenant_dn = aci_tenant.terraform_tenant.id
 relation_fv_rs_ctx = aci_vrf.terraform_vrf.id
 name = var.bd_name[2]
 description = "Created with Terraform"
}
resource "aci_subnet" "db_subnet" {
 parent_dn = aci_bridge_domain.db-bd.id
 ip = "10.1.3.1/24"
}